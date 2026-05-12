require "rails_helper"

RSpec.describe EventTime, type: :model do
  describe "lakes_of_fire start/end-time validations" do
    let(:user)  { create(:user) }
    let(:camp)  { create(:camp) }
    let(:event) do
      Event.new(
        user: user,
        title: "T",
        main_contact_person: "Person",
        contact_person_email: "p@example.test",
        event_recurrence: "single",
        event_description: "desc",
        camp: camp
      )
    end

    def build_time(starting:, ending:)
      EventTime.new(event: event, starting: starting, ending: ending, day_of_week: "Wednesday", all_day: false)
    end

    context "when starting falls within the configured Lakes of Fire year" do
      it "validates that times are within the configured start/end" do
        # An hour before LoF starts → invalid
        too_early = build_time(starting: LakesOfFireConfig.start_time - 1.hour, ending: LakesOfFireConfig.start_time + 1.hour)
        expect(too_early.valid?).to eq(false)
        expect(too_early.errors[:starting].join).to include("before Lakes of Fire Starts")

        # An hour after LoF ends → invalid
        too_late = build_time(starting: LakesOfFireConfig.end_time + 1.hour, ending: LakesOfFireConfig.end_time + 2.hours)
        expect(too_late.valid?).to eq(false)
        expect(too_late.errors[:starting].join).to include("after Lakes of Fire Ends")
      end

      it "is valid when starting and ending are inside the LoF window" do
        et = build_time(starting: LakesOfFireConfig.start_time + 1.hour, ending: LakesOfFireConfig.start_time + 2.hours)
        expect(et).to be_valid
      end
    end

    context "when starting falls in a different (prior) year" do
      # Past-year event_times exist in legacy data and should not block updates
      # to the event for unrelated reasons (e.g. merging a camp/dept).
      it "skips the start/end window validations entirely" do
        prior = LakesOfFireConfig.start_time - 2.years
        et = build_time(starting: prior, ending: prior + 1.hour)

        expect(et.valid?).to eq(true)
        expect(et.errors[:starting]).to be_empty
        expect(et.errors[:ending]).to be_empty
      end
    end

    context "when starting is blank" do
      it "doesn't raise from the conditional, presence validation still fires" do
        et = build_time(starting: nil, ending: LakesOfFireConfig.start_time + 1.hour)

        expect(et.valid?).to eq(false)
        expect(et.errors[:starting]).to include("can't be blank")
      end
    end
  end
end
