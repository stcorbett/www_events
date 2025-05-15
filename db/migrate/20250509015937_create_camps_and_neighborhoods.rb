class CreateCampsAndNeighborhoods < ActiveRecord::Migration[7.0]
  def change
    create_table :camps do |t|
      t.string :name
      t.belongs_to :location

      t.timestamps
    end

    create_table :departments do |t|
      t.string :name
      t.belongs_to :location

      t.timestamps
    end

    create_table :neighborhoods do |t|
      t.string :name
      t.integer :centerpoint_location_id

      t.timestamps
    end
  end
end
