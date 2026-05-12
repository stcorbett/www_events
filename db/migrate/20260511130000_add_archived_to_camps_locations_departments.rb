class AddArchivedToCampsLocationsDepartments < ActiveRecord::Migration[6.1]
  def change
    add_column :camps,       :archived, :boolean, default: false, null: false
    add_column :locations,   :archived, :boolean, default: false, null: false
    add_column :departments, :archived, :boolean, default: false, null: false
  end
end
