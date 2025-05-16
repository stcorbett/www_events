SELECT COALESCE(row_to_json(object_row),'{}'::json)
  FROM (
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
      SELECT
        departments.id,
        departments.name,
        (SELECT COUNT(*) FROM events WHERE events.department_id = departments.id) AS event_count
      FROM departments
      ORDER BY departments.name ASC
    )array_row)
  ) object_row
