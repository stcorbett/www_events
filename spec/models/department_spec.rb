require "rails_helper"

RSpec.describe Department, type: :model do
  describe "associated_records_not_archived (on: :create)" do
    it "is invalid when its location is archived" do
      archived_location = create(:location, archived: true)
      department = build(:department, location: archived_location)

      expect(department).not_to be_valid
      expect(department.errors[:location]).to include("is inactive, a new department needs an active location")
    end

    it "is valid when its location is not archived" do
      active_location = create(:location, archived: false)
      department = build(:department, location: active_location)

      expect(department).to be_valid
    end

    it "is valid when no location is set" do
      department = build(:department, location: nil)

      expect(department).to be_valid
    end

    it "does not re-run on update (already-created department can survive its location being archived)" do
      location = create(:location, archived: false)
      department = create(:department, location: location)
      location.update!(archived: true)

      department.name = "renamed"
      expect(department).to be_valid
      expect { department.save! }.not_to raise_error
    end
  end
end
