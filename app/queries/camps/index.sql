SELECT COALESCE(row_to_json(object_row),'{}'::json)
  FROM (
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
      SELECT
        camps.id,
        camps.name,
        camps.year,
        camps.description,
        (SELECT locations.name FROM locations WHERE locations.id = camps.location_id) AS location_name,
        (SELECT locations.archived FROM locations WHERE locations.id = camps.location_id) AS location_archived,
        camps.location_id,
        (SELECT COUNT(*) FROM events WHERE events.camp_id = camps.id) AS event_count,
        (SELECT COUNT(*) FROM events WHERE events.hosting_camp_id = camps.id) AS hosted_event_count
      FROM camps
      WHERE camps.year = {{current_year}}
        AND camps.archived = false
      ORDER BY camps.name ASC
    )array_row)
  ) object_row
