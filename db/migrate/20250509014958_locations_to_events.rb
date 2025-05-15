class LocationsToEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.string :type
      t.string :camp_site_identifier
      t.belongs_to :neighborhood

      t.float :lat
      t.float :lng

      t.timestamps
    end

    remove_column :events, :hosting_location, :string
    
    add_column :events, :location_id, :integer

    add_column :events, :who, :string
    add_column :events, :where, :string
  end
end
