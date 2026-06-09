require "rails_helper"

RSpec.describe Camp, type: :model do
  describe "validations" do
    it "allows the same name in different years" do
      create(:camp, name: "Camp Intermittent", year: 2025)

      camp = build(:camp, name: "Camp Intermittent", year: 2026)

      expect(camp).to be_valid
    end

    it "requires names to be unique within a year" do
      create(:camp, name: "Camp Same Year", year: 2026)

      camp = build(:camp, name: "Camp Same Year", year: 2026)

      expect(camp).not_to be_valid
      expect(camp.errors[:name]).to include("has already been taken")
    end
  end

  describe "associated_records_not_archived (on: :create)" do
    it "is invalid when its location is archived" do
      archived_location = create(:location, archived: true)
      camp = build(:camp, location: archived_location)

      expect(camp).not_to be_valid
      expect(camp.errors[:location]).to include("is inactive, a new camp needs an active location")
    end

    it "is valid when its location is not archived" do
      active_location = create(:location, archived: false)
      camp = build(:camp, location: active_location)

      expect(camp).to be_valid
    end

    it "is valid when no location is set" do
      camp = build(:camp, location: nil)

      expect(camp).to be_valid
    end

    it "does not re-run on update (already-created camp can survive its location being archived)" do
      location = create(:location, archived: false)
      camp = create(:camp, location: location)
      location.update!(archived: true)

      camp.name = "renamed"
      expect(camp).to be_valid
      expect { camp.save! }.not_to raise_error
    end
  end

  describe "valid?(:merge)" do
    # Camps have no merge-blocking validations — anything that points at a Camp
    # (events, hosted_events) is moved by the merge itself. This spec locks in
    # that camps remain mergeable so the validation framework doesn't drift.
    it "is valid (camps have no merge-blocking dependents)" do
      camp = create(:camp)
      Event # ensure constant is loaded so future merge_events! can run
      expect(camp.valid?(:merge)).to eq(true)
    end
  end
end
