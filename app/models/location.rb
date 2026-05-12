class Location < ActiveRecord::Base
  belongs_to :neighborhood, optional: true
  has_many :events
  has_one :camp
  has_many :departments

  PRECISION_VALUES = ["specific", "broad"].freeze

  validates :name, uniqueness: true, allow_blank: true
  validates :precision, inclusion: { in: PRECISION_VALUES, message: "%{value} is not a valid precision value" }
  validates :precision, presence: true

  validates :lat, numericality: true, allow_nil: true
  validates :lng, numericality: true, allow_nil: true

  scope :archived,     -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }

  validate :no_dependent_camp_or_departments, on: :merge

  before_destroy :check_for_events

  private

  def no_dependent_camp_or_departments
    if camp.present?
      errors.add(:base, "Camp '#{camp.name}' (id=#{camp.id}) is still attached to this location — merge this camp first, or detach it.")
    end
    dept_count = departments.count
    if dept_count > 0
      names = departments.order(:name).limit(3).pluck(:name)
      suffix = dept_count > 3 ? ", ..." : ""
      errors.add(:base, "#{dept_count} department#{'s' unless dept_count == 1} still reference this location (#{names.join(', ')}#{suffix}).")
    end
  end

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete location with associated events.")
      throw(:abort) # This prevents the destroy action from completing
    end
  end
end
