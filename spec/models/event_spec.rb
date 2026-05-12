require "rails_helper"

RSpec.describe Event, type: :model do
  describe ".ordered_by_first_event_time" do
    let(:user) { create(:user) }
    let(:base) { LakesOfFireConfig.start_time }

    def make_event(title, *starting_times)
      event = Event.new(
        user: user, title: title, main_contact_person: "x", contact_person_email: "x@x.test",
        event_recurrence: starting_times.size == 1 ? "single" : "multiple", event_description: "x"
      )
      starting_times.each do |s|
        event.event_times.build(starting: s, ending: s + 1.hour, day_of_week: "Wednesday", all_day: false)
      end
      event.save!(validate: false)
      event
    end

    it "sorts events ascending by earliest event_time.starting" do
      late  = make_event("Z late",   base + 3.hours)
      early = make_event("A early",  base + 1.hour)
      mid   = make_event("M middle", base + 2.hours)

      expect(Event.where(id: [late.id, early.id, mid.id]).ordered_by_first_event_time).to eq([early, mid, late])
    end

    it "uses the earliest of multiple event_times for an event" do
      a = make_event("A single",       base + 1.hour)
      b = make_event("B multi", base + 4.hours, base + 0.5.hours) # earliest = 0.5h

      expect(Event.where(id: [a.id, b.id]).ordered_by_first_event_time).to eq([b, a])
    end

    it "places events with no event_times at the end (NULLS LAST)" do
      no_times = Event.new(user: user, title: "no-times",
                           main_contact_person: "x", contact_person_email: "x@x.test",
                           event_recurrence: "single", event_description: "x")
      no_times.save!(validate: false)
      withe = make_event("withe", base + 1.hour)

      expect(Event.where(id: [no_times.id, withe.id]).ordered_by_first_event_time).to eq([withe, no_times])
    end

    it "breaks ties by title for a deterministic order" do
      a = make_event("Beta",  base + 1.hour)
      b = make_event("Alpha", base + 1.hour)

      expect(Event.where(id: [a.id, b.id]).ordered_by_first_event_time).to eq([b, a])
    end

    it "is chainable from an association without losing partition order" do
      camp = create(:camp)
      late  = make_event("late",  base + 3.hours).tap  { |e| e.update_columns(camp_id: camp.id) }
      early = make_event("early", base + 1.hour).tap   { |e| e.update_columns(camp_id: camp.id) }

      ordered = camp.events.ordered_by_first_event_time.includes(:event_times)
      expect(ordered.to_a).to eq([early, late])
    end
  end

  describe "associated_records_not_archived (on: :create)" do
    # We don't construct a fully-valid Event for these specs — we only assert
    # whether the specific archived-association errors are present (or absent).
    # Other validation errors (event_times, where_object, etc.) are tolerated.

    let(:user) { create(:user) }

    def build_event(attrs = {})
      Event.new({
        user: user,
        title: "T",
        main_contact_person: "Person",
        contact_person_email: "p@example.test",
        event_recurrence: "single",
        event_description: "desc"
      }.merge(attrs))
    end

    it "is invalid when its camp is archived" do
      archived_camp = create(:camp, archived: true)
      event = build_event(camp: archived_camp)

      event.valid?
      expect(event.errors[:camp]).to include("is inactive, a new event needs an active camp")
    end

    it "is invalid when its hosting_camp is archived" do
      archived_camp = create(:camp, archived: true)
      event = build_event(hosting_camp: archived_camp)

      event.valid?
      expect(event.errors[:hosting_camp]).to include("is inactive, a new event needs an active hosting camp")
    end

    it "is invalid when its location is archived" do
      archived_location = create(:location, archived: true)
      event = build_event(location: archived_location)

      event.valid?
      expect(event.errors[:location]).to include("is inactive, a new event needs an active location")
    end

    it "is invalid when its department is archived" do
      archived_department = create(:department, archived: true)
      event = build_event(department: archived_department)

      event.valid?
      expect(event.errors[:department]).to include("is inactive, a new event needs an active department")
    end

    it "accumulates all archived-association errors at once" do
      archived_camp       = create(:camp,       archived: true)
      archived_location   = create(:location,   archived: true)
      archived_department = create(:department, archived: true)
      event = build_event(
        camp:         archived_camp,
        hosting_camp: archived_camp,
        location:     archived_location,
        department:   archived_department
      )

      event.valid?
      expect(event.errors[:camp]).        to include("is inactive, a new event needs an active camp")
      expect(event.errors[:hosting_camp]).to include("is inactive, a new event needs an active hosting camp")
      expect(event.errors[:location]).    to include("is inactive, a new event needs an active location")
      expect(event.errors[:department]).  to include("is inactive, a new event needs an active department")
    end

    it "does not add archived errors when all associations are active" do
      event = build_event(
        camp:         create(:camp,       archived: false),
        hosting_camp: create(:camp,       archived: false),
        location:     create(:location,   archived: false),
        department:   create(:department, archived: false)
      )

      event.valid?
      expect(event.errors[:camp]).         to be_empty
      expect(event.errors[:hosting_camp]). to be_empty
      expect(event.errors[:location]).     to be_empty
      expect(event.errors[:department]).   to be_empty
    end

    it "does not re-check on update (an associated record archived later does not block updates)" do
      camp = create(:camp, archived: false)
      event = build_event(camp: camp, hosting_camp: camp)
      # Build_event isn't fully valid (no event_times/etc.), so persist directly to skip those concerns.
      event.save(validate: false)
      camp.update!(archived: true)

      event.title = "renamed"
      event.valid? # runs update validations only

      expect(event.errors[:camp]).         to be_empty
      expect(event.errors[:hosting_camp]). to be_empty
    end
  end
end
