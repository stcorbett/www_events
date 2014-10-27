class CreateEventTimes < ActiveRecord::Migration
  def change
    create_table :event_times do |t|
      t.integer :event_id
      t.datetime :starting, :ending

      t.timestamps
    end
  end
end
