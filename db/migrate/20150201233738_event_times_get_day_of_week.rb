class EventTimesGetDayOfWeek < ActiveRecord::Migration[6.1]
  def change
    add_column :event_times, :day_of_week, :string
  end
end
