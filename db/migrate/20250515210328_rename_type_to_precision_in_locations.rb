class RenameTypeToPrecisionInLocations < ActiveRecord::Migration[7.0]
  def change
    rename_column :locations, :type, :precision
  end
end
