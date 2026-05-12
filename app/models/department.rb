class Department < ActiveRecord::Base
  belongs_to :location, optional: true
  has_many :events

  validates :name, presence: true

  scope :archived,     -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }

  before_destroy :check_for_events

  private

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete department with associated events. Please reassign or delete events first.")
      throw(:abort)
    end
    # Add checks for other important associations here if needed in the future
  end
end
