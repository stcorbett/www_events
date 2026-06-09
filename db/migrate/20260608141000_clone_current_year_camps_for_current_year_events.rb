class CloneCurrentYearCampsForCurrentYearEvents < ActiveRecord::Migration[7.0]
  CURRENT_YEAR = 2026
  CURRENT_YEAR_CUTOFF = Date.new(CURRENT_YEAR, 1, 1)

  class Camp < ActiveRecord::Base
    self.table_name = "camps"
  end

  class Event < ActiveRecord::Base
    self.table_name = "events"
  end

  def up
    now = Time.current

    old_camps_with_current_events.find_each do |old_camp|
      current_year_camp = find_or_clone_current_year_camp(old_camp, now)

      current_year_events.where(camp_id: old_camp.id).update_all(
        camp_id: current_year_camp.id,
        updated_at: now
      )

      current_year_events.where(hosting_camp_id: old_camp.id).update_all(
        hosting_camp_id: current_year_camp.id,
        updated_at: now
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def old_camps_with_current_events
    Camp.where.not(year: CURRENT_YEAR).where(
      <<~SQL.squish,
        EXISTS (
          SELECT 1
          FROM events
          WHERE events.camp_id = camps.id
            AND events.created_at > :current_year_cutoff
        )
        OR EXISTS (
          SELECT 1
          FROM events
          WHERE events.hosting_camp_id = camps.id
            AND events.created_at > :current_year_cutoff
        )
      SQL
      current_year_cutoff: CURRENT_YEAR_CUTOFF
    )
  end

  def current_year_events
    Event.where("created_at > ?", CURRENT_YEAR_CUTOFF)
  end

  def find_or_clone_current_year_camp(old_camp, now)
    Camp.find_by(name: old_camp.name, year: CURRENT_YEAR) ||
      Camp.create!(
        name: old_camp.name,
        location_id: old_camp.location_id,
        description: old_camp.description,
        archived: old_camp.archived,
        year: CURRENT_YEAR,
        created_at: now,
        updated_at: now
      )
  end
end
