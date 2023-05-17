SELECT COALESCE(row_to_json(object_row),'{}'::json)
  FROM (
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (  SELECT
      events.id AS event_id,
      events.title,
      events.event_description,
      events.site_id,
      events.hosting_location,
      events.event_recurrence,
      events.heart_count,
      events.alcohol,
      events.red_light,
      events.fire_art,
      events.spectacle,
      events.crafting,
      events.food,
      events.sober,
      (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (      SELECT
        event_times.id AS event_time_id,
        event_times.starting,
        event_times.ending,
        event_times.day_of_week,
        event_times.all_day
      FROM event_times
        WHERE event_times.event_id = events.id
      )array_row) AS event_times
      FROM events
      WHERE
        EXISTS (
          SELECT 1
          FROM event_times
            WHERE event_times.event_id = events.id
            AND event_times.starting >= '{{burn_start}}'
            AND event_times.ending <= '{{burn_end}}'
        )
      )array_row)
    ) object_row
