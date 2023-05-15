class EventsGetCategories < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :alcohol,   :boolean
    add_column :events, :red_light, :boolean
    add_column :events, :fire_art,  :boolean
  end
end
