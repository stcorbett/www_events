require "rails_helper"

RSpec.describe Location, type: :model do
  describe "valid?(:merge)" do
    it "is valid when no camp or department references this location" do
      location = create(:location)

      expect(location.valid?(:merge)).to eq(true)
    end

    it "is invalid when a camp references this location" do
      location = create(:location)
      camp = Camp.create!(name: "Test Camp", location: location)
      location.reload # refresh has_one :camp association

      expect(location.valid?(:merge)).to eq(false)
      expect(location.errors[:base].join).to include("Camp '#{camp.name}'", "still attached")
    end

    it "is invalid when a department references this location" do
      location = create(:location)
      Department.create!(name: "Test Dept", location: location)

      expect(location.valid?(:merge)).to eq(false)
      expect(location.errors[:base].join).to include("department", "Test Dept")
    end

    it "accumulates both errors when both a camp and a department reference this location" do
      location = create(:location)
      Camp.create!(name: "Test Camp", location: location)
      Department.create!(name: "Test Dept", location: location)
      location.reload

      expect(location.valid?(:merge)).to eq(false)
      expect(location.errors[:base].size).to eq(2)
    end

    it "pluralizes the department count message" do
      location = create(:location)
      3.times { |i| Department.create!(name: "Dept #{i}", location: location) }

      location.valid?(:merge)
      expect(location.errors[:base].join).to include("3 departments still reference")
    end

    it "regular save/update of the location is unaffected by the merge validation" do
      location = create(:location)
      Camp.create!(name: "Blocking Camp", location: location)
      location.reload

      # The :merge context fails, but routine updates should still succeed.
      expect(location.valid?(:merge)).to eq(false)
      expect(location.update(name: "Renamed")).to eq(true)
    end
  end
end
