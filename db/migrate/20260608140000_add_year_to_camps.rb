class AddYearToCamps < ActiveRecord::Migration[7.0]
  def up
    add_column :camps, :year, :integer

    execute <<~SQL.squish
      UPDATE camps
      SET year = EXTRACT(YEAR FROM created_at)::integer
    SQL

    change_column_null :camps, :year, false
    add_index :camps, [:name, :year], unique: true
  end

  def down
    remove_index :camps, [:name, :year]
    remove_column :camps, :year
  end
end
