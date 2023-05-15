class EventsGetHeartCount < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :heart_count, :integer, default: 0
  end
end
