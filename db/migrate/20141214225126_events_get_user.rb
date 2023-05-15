class EventsGetUser < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :user_id, :integer
  end
end
