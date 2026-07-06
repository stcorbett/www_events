module Superadmin
  module EventsHelper
    def superadmin_event_camp_affiliations(event)
      location_camps = event.location&.camps || []
      camps = [
        event.camp,
        event.hosting_camp,
        *location_camps
      ].compact.uniq(&:id)

      return "none" if camps.empty?

      safe_join(
        camps.map { |camp| admin_associated_record_label(camp, record_type_name: "camp") },
        ", "
      )
    end

    def superadmin_event_times(event)
      event.event_times.sort_by { |event_time| event_time.starting || Time.zone.at(0) }.map do |event_time|
        [
          event_time.day_of_week.presence,
          superadmin_event_time_range(event_time)
        ].compact.join(", ")
      end.presence || ["No scheduled times"]
    end

    def superadmin_event_categories(event)
      event.categories.map { |category| category.to_s.humanize }.presence&.join(", ") || "none"
    end

    def superadmin_event_submitter(event)
      return "unknown" unless event.user.present?

      [event.user.name, event.user.email].compact.join(" / ")
    end

    private

    def superadmin_event_time_range(event_time)
      return "All day" if event_time.all_day?

      [
        event_time.starting&.strftime("%-l:%M %p"),
        event_time.ending&.strftime("%-l:%M %p")
      ].compact.join(" - ")
    end
  end
end
