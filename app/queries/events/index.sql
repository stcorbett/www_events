SELECT COALESCE(row_to_json(object_row),'{}'::json)
  FROM (
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (  SELECT
      events.id AS event_id,
      events.title,
      events.event_description,
      events.site_id,
      CASE
        WHEN events.camp_id IS NOT NULL THEN 'camp'
        WHEN events.location_id IS NOT NULL THEN
          CASE
            WHEN locations.precision = 'specific' THEN 'location'
            WHEN locations.precision = 'broad' THEN 'multiple_locations'
            ELSE NULL
          END
        ELSE NULL
      END AS where_type,
      CASE
        WHEN events.camp_id IS NOT NULL THEN camps.name
        WHEN events.location_id IS NOT NULL THEN locations.name
        ELSE NULL
      END AS where_name,
      CASE
        WHEN events.hosting_camp_id IS NOT NULL THEN 'camp'
        WHEN events.department_id IS NOT NULL THEN 'lakes_of_fire'
        ELSE 'just_me'
      END AS who_type,
      CASE
        WHEN events.hosting_camp_id IS NOT NULL THEN hosting_camps.name
        WHEN events.department_id IS NOT NULL THEN departments.name
        ELSE events.main_contact_person
      END AS who_name,
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
      LEFT JOIN camps ON events.camp_id = camps.id
      LEFT JOIN locations ON events.location_id = locations.id
      LEFT JOIN camps hosting_camps ON events.hosting_camp_id = hosting_camps.id
      LEFT JOIN departments ON events.department_id = departments.id
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
