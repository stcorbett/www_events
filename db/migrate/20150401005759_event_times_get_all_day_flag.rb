class EventTimesGetAllDayFlag < ActiveRecord::Migration
  def change
    add_column :event_times, :all_day, :boolean
  end
end
