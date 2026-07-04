class AddForeignKeyToEventsHostingCampId < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :events, :camps, column: :hosting_camp_id, validate: false
  end
end
