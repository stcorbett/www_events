class AddDescriptionToCamps < ActiveRecord::Migration[7.0]
  def change
    add_column :camps, :description, :text
  end
end
