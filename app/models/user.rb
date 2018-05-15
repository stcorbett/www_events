class User < ActiveRecord::Base

  has_many :events

  store :hearts

  def self.create_or_authorize(auth)
    where(auth.to_hash.slice("provider", "uid")).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.image = auth.info.image
      user.token = auth.credentials.token
      user.expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def editable_events
    Event.configured_year.joins(:user).where("users.email = ?", self.email)
  end

  def heart_for?(event_time)
    return unless event_time.is_a?(EventTime)
    (hearts[LakesOfFireConfig.year] || []).include?(event_time.id)
  end

  def add_heart(event_time)
    return if heart_for?(event_time)

    hearts[LakesOfFireConfig.year] = [] unless hearts[LakesOfFireConfig.year].is_a?(Array)
    hearts[LakesOfFireConfig.year] << event_time.id
  end

  def remove_heart(event_time)
    return unless heart_for?(event_time)

    hearts[LakesOfFireConfig.year] -= [event_time.id]
  end

end
