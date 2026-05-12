class Department < ActiveRecord::Base
  belongs_to :location, optional: true
  has_many :events

  validates :name, presence: true

  scope :archived,     -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }

  validate :associated_records_not_archived, on: :create

  before_destroy :check_for_events

  private

  def associated_records_not_archived
    errors.add(:location, "is inactive, a new department needs an active location") if location&.archived
  end

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete department with associated events. Please reassign or delete events first.")
      throw(:abort)
    end
    # Add checks for other important associations here if needed in the future
  end
end
