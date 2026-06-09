require "rails_helper"
require Rails.root.join("db/migrate/20260608141000_clone_current_year_camps_for_current_year_events").to_s

RSpec.describe CloneCurrentYearCampsForCurrentYearEvents, type: :migration do
  let(:migration) { described_class.new }
  let(:user) { create(:user) }

  it "clones previous-year camps and reparents their current-year events" do
    location = create(:location)
    old_camp = create(:camp, name: "Cross-Year Camp", year: 2025, location: location, description: "Original notes")
    current_event = event_for(old_camp, created_at: Time.zone.local(2026, 5, 1))
    past_event = event_for(old_camp, created_at: Time.zone.local(2025, 5, 1))

    expect { migration.up }.to change { Camp.where(name: old_camp.name, year: 2026).count }.by(1)

    current_year_camp = Camp.find_by!(name: old_camp.name, year: 2026)
    expect(current_year_camp.location).to eq(location)
    expect(current_year_camp.description).to eq("Original notes")

    expect(current_event.reload.camp).to eq(current_year_camp)
    expect(current_event.hosting_camp).to eq(current_year_camp)

    expect(past_event.reload.camp).to eq(old_camp)
    expect(past_event.hosting_camp).to eq(old_camp)
  end

  it "uses an existing current-year camp instead of creating a duplicate" do
    old_camp = create(:camp, name: "Already Current", year: 2025)
    current_year_camp = create(:camp, name: "Already Current", year: 2026)
    current_event = event_for(old_camp, created_at: Time.zone.local(2026, 5, 1))

    expect { migration.up }.not_to change { Camp.where(name: old_camp.name, year: 2026).count }

    expect(current_event.reload.camp).to eq(current_year_camp)
    expect(current_event.hosting_camp).to eq(current_year_camp)
  end

  def event_for(camp, created_at:)
    event = Event.new(
      user: user,
      title: "Migration Event #{SecureRandom.hex(2)}",
      main_contact_person: "Person",
      contact_person_email: "person@example.test",
      event_recurrence: "single",
      event_description: "desc",
      camp: camp,
      hosting_camp: camp
    )
    event.event_times.build(
      starting: LakesOfFireConfig.start_time + 1.hour,
      ending: LakesOfFireConfig.start_time + 2.hours,
      day_of_week: "Wednesday",
      all_day: false
    )
    event.save!
    event.update_columns(created_at: created_at, updated_at: created_at)
    event
  end
end
