class AddCampRefToEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :events, :camp, null: true, foreign_key: true
  end
end
