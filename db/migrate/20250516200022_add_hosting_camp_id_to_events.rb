class AddHostingCampIdToEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :events, :hosting_camp_id, :integer
    add_index :events, :hosting_camp_id
  end
end
