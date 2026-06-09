class Camp < ActiveRecord::Base
  belongs_to :location, optional: true
  has_many :events
  has_many :hosted_events, class_name: 'Event', foreign_key: 'hosting_camp_id'
  accepts_nested_attributes_for :location, reject_if: :all_blank

  before_validation :set_default_year, on: :create

  validates :name, uniqueness: { scope: :year }, presence: true
  validates :year, presence: true, numericality: { only_integer: true }

  scope :archived,     -> { where(archived: true) }
  scope :not_archived, -> { where(archived: false) }
  scope :for_year,     ->(year) { where(year: year) }
  scope :current_year, -> { for_year(LakesOfFireConfig.year) }

  validate :associated_records_not_archived, on: :create

  before_destroy :check_for_events

  private

  def set_default_year
    self.year ||= LakesOfFireConfig.year
  end

  def associated_records_not_archived
    errors.add(:location, "is inactive, a new camp needs an active location") if location&.archived
  end

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete camp with associated events. Please reassign or delete events first.")
      throw(:abort) # This prevents the destroy action from completing
    end
  end
end
