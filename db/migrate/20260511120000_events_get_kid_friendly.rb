class EventsGetKidFriendly < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :kid_friendly, :boolean
  end
end
