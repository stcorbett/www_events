module ApplicationHelper

  def admin_badge(user)
    if user.admin
      "<span class='badge label-success'>admin</span>"
    end
  end

  def event_requirements_start_time
    start_time = LakesOfFireConfig.start_time
    start_time.strftime("%l%p on %B #{ start_time.day.ordinalize }")
  end

  def event_requirements_end_time
    end_time = LakesOfFireConfig.end_time
    end_time.strftime("%l%p on %B #{ end_time.day.ordinalize }")
  end

  def abbr_event_days(event)
    event.event_times.order("event_times.starting ASC").collect{|event_time| event_time.abbr_day }.join(", ")
  end

  def admin_archived_record_marker(record_type_name)
    content_tag(
      :span,
      "archived #{record_type_name}",
      class: "badge bg-danger fw-bold ms-2 align-middle",
      title: "this #{record_type_name} is archived"
    )
  end

  def admin_associated_record_label(record, record_type_name:, text: nil, path: nil)
    label = text.presence || record&.name.presence || "#{record_type_name} ##{record&.id}"
    title = "this #{record_type_name} is archived"

    linked_or_plain_label =
      if path.present?
        link_to(label, path, class: ("text-white fw-bold" if record&.archived?), title: (title if record&.archived?))
      else
        content_tag(:span, label)
      end

    return linked_or_plain_label unless record&.archived?

    safe_join(
      [
        content_tag(:span, linked_or_plain_label, class: "bg-danger text-white fw-bold px-1 rounded", title: title),
        " ",
        admin_archived_record_marker(record_type_name)
      ]
    )
  end

  def admin_event_where_label(event, link: false)
    admin_event_associated_record_label(event.where_object, event.human_location, link: link)
  end

  def admin_event_who_label(event, link: false)
    admin_event_associated_record_label(event.who_object, event.human_who, link: link)
  end

  def admin_record_type_name(record)
    case record
    when Camp
      "camp"
    when Location
      "location"
    when Department
      "department"
    else
      record.class.name.demodulize.underscore.humanize.downcase
    end
  end

  def admin_record_path(record)
    case record
    when Camp
      admin_camp_path(record)
    when Location
      admin_location_path(record)
    when Department
      admin_department_path(record)
    end
  end

  private

  def admin_event_associated_record_label(record, text, link:)
    return text unless record.present?

    admin_associated_record_label(
      record,
      record_type_name: admin_record_type_name(record),
      text: text,
      path: (admin_record_path(record) if link)
    )
  end

end
