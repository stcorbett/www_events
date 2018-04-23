class EventsGetHeartCount < ActiveRecord::Migration
  def change
    add_column :events, :heart_count, :integer, default: 0
  end
end
