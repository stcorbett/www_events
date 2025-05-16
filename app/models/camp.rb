class Camp < ActiveRecord::Base
  belongs_to :location, optional: true
  has_many :events
  has_many :hosted_events, class_name: 'Event', foreign_key: 'hosting_camp_id'

  validates :name, uniqueness: true, presence: true

  before_destroy :check_for_events

  private

  def check_for_events
    if events.any?
      errors.add(:base, "Cannot delete camp with associated events. Please reassign or delete events first.")
      throw(:abort) # This prevents the destroy action from completing
    end
  end
end
