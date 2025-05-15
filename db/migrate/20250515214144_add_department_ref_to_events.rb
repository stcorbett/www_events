class AddDepartmentRefToEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :department, null: true, foreign_key: true
  end
end
