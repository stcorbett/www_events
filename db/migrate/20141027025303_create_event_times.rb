class CreateEventTimes < ActiveRecord::Migration[6.1]
  def change
    create_table :event_times do |t|
      t.integer :event_id
      t.datetime :starting, :ending

      t.timestamps
    end
  end
end
