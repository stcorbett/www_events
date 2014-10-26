class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :hosting_location
      t.string :main_contact_person
      t.string :contact_person_email
      t.string :event_recurrence

      t.datetime :wednesday_start, :thursday_start, :friday_start, :saturday_start, :sunday_start
      t.float :wednesday_duration, :thursday_duration, :friday_duration, :saturday_duration, :sunday_duration

      t.text :event_description

      t.timestamps
    end
  end
end
