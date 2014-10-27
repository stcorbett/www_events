class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :hosting_location
      t.string :main_contact_person
      t.string :contact_person_email
      t.string :event_recurrence

      t.datetime :single_occurrence_start
      t.integer :single_occurrence_duration_minutes

      t.datetime :wednesday_start, :thursday_start, :friday_start, :saturday_start, :sunday_start
      t.float :wednesday_duration_minutes, :thursday_duration_minutes, :friday_duration_minutes, :saturday_duration_minutes, :sunday_duration_minutes

      t.text :event_description

      t.timestamps
    end
  end
end
