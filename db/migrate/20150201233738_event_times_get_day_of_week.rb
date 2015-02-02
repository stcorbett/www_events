class EventTimesGetDayOfWeek < ActiveRecord::Migration
  def change
    add_column :event_times, :day_of_week, :string
  end
end
