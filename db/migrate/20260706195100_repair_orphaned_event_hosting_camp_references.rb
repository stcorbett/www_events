class RepairOrphanedEventHostingCampReferences < ActiveRecord::Migration[7.0]
  def up
    execute <<~SQL.squish
      UPDATE events
      SET hosting_camp_id = 238,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = 1011
        AND hosting_camp_id IN (98, 130)
        AND EXISTS (SELECT 1 FROM camps WHERE id = 238)
    SQL

    execute <<~SQL.squish
      UPDATE events
      SET hosting_camp_id = 353,
          updated_at = CURRENT_TIMESTAMP
      WHERE id = 1045
        AND hosting_camp_id IN (126, 131)
        AND EXISTS (SELECT 1 FROM camps WHERE id = 353)
    SQL
  end

  def down
    # Do not recreate orphaned hosting_camp_id references on rollback.
  end
end
