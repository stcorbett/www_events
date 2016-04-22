class EventsGetSiteId < ActiveRecord::Migration
  def change
    add_column :events, :site_id, :string
  end
end
