class EventTimesGetAllDayFlag < ActiveRecord::Migration[6.1]
  def change
    add_column :event_times, :all_day, :boolean
  end
end
