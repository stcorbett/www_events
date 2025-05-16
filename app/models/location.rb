class Location < ActiveRecord::Base
  belongs_to :neighborhood, optional: true
  has_many :events

  PRECISION_VALUES = ["specific", "broad"].freeze

  validates :name, uniqueness: true, presence: true

  validates :precision, inclusion: { in: PRECISION_VALUES, message: "%{value} is not a valid precision value" }
  validates :precision, presence: true
  
  validates :lat, numericality: true, allow_nil: true
  validates :lng, numericality: true, allow_nil: true

  before_destroy :check_for_events

  private

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete location with associated events.")
      throw(:abort) # This prevents the destroy action from completing
    end
  end
end
