class LakesOfFireConfig
  class << self

    def start_time
      Time.zone.local(2015, 6, 17, 12, 0)
    end

    def end_time
      Time.zone.local(2015, 6, 21, 15, 0)
    end

    def event_days
      {
        wednesday:  Date.new(2015, 6, 17),
        thursday:   Date.new(2015, 6, 18),
        friday:     Date.new(2015, 6, 19),
        saturday:   Date.new(2015, 6, 20),
        sunday:     Date.new(2015, 6, 21)
      }
    end

    def event_day_names
      event_days.values.collect do |day|
        day.strftime("%A")
      end
    end

  end
end