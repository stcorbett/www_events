{{#array}}
  SELECT
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
    {{#array}}
      SELECT
        event_times.starting,
        event_times.ending,
        event_times.day_of_week,
        event_times.all_day
      FROM event_times
        WHERE event_times.event_id = events.id
    {{/array}} AS event_times
  FROM events
{{/array}}
