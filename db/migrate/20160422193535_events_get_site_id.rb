class EventsGetSiteId < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :site_id, :string
  end
end
