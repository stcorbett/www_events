class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :hosting_location
      t.string :main_contact_person
      t.string :contact_person_email
      t.string :event_recurrence

      t.text :event_description

      t.timestamps
    end
  end
end
