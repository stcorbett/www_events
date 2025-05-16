SELECT COALESCE(row_to_json(object_row),'{}'::json)
  FROM (
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
      SELECT
        locations.id,
        locations.name,
        locations.precision,
        locations.lat,
        locations.lng,
        locations.camp_site_identifier,
        (SELECT COUNT(*) FROM events WHERE events.location_id = locations.id) AS event_count,
        (SELECT COUNT(*) FROM camps WHERE camps.location_id = locations.id) AS camp_count
      FROM locations
      ORDER BY locations.name ASC
    )array_row)
  ) object_row
