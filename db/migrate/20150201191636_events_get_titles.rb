class EventsGetTitles < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :title, :string
  end
end
