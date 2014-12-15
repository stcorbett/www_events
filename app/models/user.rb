class User < ActiveRecord::Base

  has_many :events

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
    Event.joins(:user).where("users.email = ?", self.email)
  end

end