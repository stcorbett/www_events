require 'rails_helper'

RSpec.describe EventTime, type: :model do
  include ActionView::Helpers::DateHelper

  # Assuming LakesOfFireConfig is a module that provides necessary configuration
  let(:start_date) { Time.zone.parse('2023-06-01') }
  let(:end_date) { Time.zone.parse('2023-06-05') }
  let(:event_days) { { monday: start_date, tuesday: start_date + 1.day } }
  let(:start_time) { Time.zone.parse('2023-06-01 10:00:00') }
  let(:end_time) { Time.zone.parse('2023-06-01 12:00:00') }

  before do
    stub_const('LakesOfFireConfig', double('LakesOfFireConfig', start_date: start_date, end_time: end_date, event_days: event_days, start_time: start_date))
  end

  describe 'associations' do
    it { should belong_to(:event) }
  end

  describe 'validations' do
    it { should validate_presence_of(:starting) }
    it { should validate_presence_of(:ending) }

    context 'custom validations' do
      let(:event_time) { EventTime.new(starting: starting, ending: ending) }

      context 'when starting before Lakes of Fire' do
        let(:starting) { start_date - 1.day }
        let(:ending) { start_date + 1.hour }

        it 'adds an error on starting' do
          event_time.valid?
          expect(event_time.errors[:starting]).to include("Can't start before Lakes of Fire Starts!")
        end
      end

      context 'when ending after Lakes of Fire' do
        let(:starting) { end_date - 1.hour }
        let(:ending) { end_date + 1.day }

        it 'adds an error on ending' do
          event_time.valid?
          expect(event_time.errors[:ending]).to include("Can't end after Lakes of Fire Ends!")
        end
      end
    end
  end

  describe 'scopes' do
    describe '.configured_year' do
      it 'returns events starting after LakesOfFireConfig start date' do
        event_time = EventTime.create!(starting: start_date + 1.day, ending: end_date - 1.day)
        expect(EventTime.configured_year).to include(event_time)
      end
    end
  end

  describe '.start_and_end_from_inputs' do
    it 'calculates starting and ending times correctly' do
      starting, ending = EventTime.start_and_end_from_inputs('monday', '10:00', '12:00')
      expect(starting).to eq(Time.zone.local(start_date.year, start_date.month, start_date.day, 10, 0))
      expect(ending).to eq(Time.zone.local(start_date.year, start_date.month, start_date.day, 12, 0))
    end

    it 'adjusts ending time to next day if starting is after ending' do
      starting, ending = EventTime.start_and_end_from_inputs('monday', '23:00', '01:00')
      expect(ending).to eq(Time.zone.local(start_date.year, start_date.month, start_date.day + 1, 1, 0))
    end
  end

  describe '#start_date' do
    it 'returns formatted start date' do
      event_time = EventTime.new(starting: start_time)
      expect(event_time.start_date).to eq('06-01-2023')
    end
  end

  describe '#start_time' do
    it 'returns formatted start time' do
      event_time = EventTime.new(starting: start_time)
      expect(event_time.start_time).to eq('10:00AM')
    end

    it 'returns nil if starting is nil' do
      event_time = EventTime.new(starting: nil)
      expect(event_time.start_time).to be_nil
    end
  end

  describe '#end_date' do
    it 'returns formatted end date' do
      event_time = EventTime.new(ending: end_time)
      expect(event_time.end_date).to eq('06-01-2023')
    end
  end

  describe '#end_time' do
    it 'returns formatted end time' do
      event_time = EventTime.new(ending: end_time)
      expect(event_time.end_time).to eq('12:00PM')
    end

    it 'returns nil if ending is nil' do
      event_time = EventTime.new(ending: nil)
      expect(event_time.end_time).to be_nil
    end
  end

  describe '#abbr_day' do
    it 'returns abbreviated day of the week' do
      event_time = EventTime.new(starting: start_time)
      expect(event_time.abbr_day).to eq('Th')
    end
  end

  describe '#duration_human' do
    it 'returns human-readable duration' do
      event_time = EventTime.new(starting: start_time, ending: end_time)
      expect(event_time.duration_human).to eq('2 hours')
    end
  end

  describe '#human_time' do
    context 'when all_day is true' do
      it 'returns "All Day"' do
        event_time = EventTime.new(all_day: true)
        expect(event_time.human_time).to eq('All Day')
      end
    end

    context 'when all_day is false' do
      it 'returns formatted time and duration' do
        event_time = EventTime.new(starting: start_time, ending: end_time, all_day: false)
        expect(event_time.human_time).to eq('10:00 AM | 2 hours')
      end
    end
  end

  describe '#day_of_event_index' do
    it 'returns index of the day of the event' do
      event_time = EventTime.new(day_of_week: 'monday')
      expect(event_time.day_of_event_index).to eq(0)
    end
  end

  describe '#day_of_event' do
    it 'returns the date of the event day' do
      event_time = EventTime.new(day_of_week: 'monday')
      expect(event_time.day_of_event).to eq(start_date)
    end
  end

  describe '#starting_at_start_of_day?' do
    it 'returns true if starting at the start of the day' do
      event_time = EventTime.new(starting: start_date)
      expect(event_time.starting_at_start_of_day?).to be true
    end

    it 'returns false if not starting at the start of the day' do
      event_time = EventTime.new(starting: start_date + 1.hour)
      expect(event_time.starting_at_start_of_day?).to be false
    end
  end

  describe '#ending_at_end_of_day?' do
    it 'returns true if ending at the end of the day' do
      event_time = EventTime.new(ending: end_date)
      expect(event_time.ending_at_end_of_day?).to be true
    end

    it 'returns false if not ending at the end of the day' do
      event_time = EventTime.new(ending: end_date - 1.hour)
      expect(event_time.ending_at_end_of_day?).to be false
    end
  end

  describe 'callbacks' do
    describe 'before_save :set_all_day_flag' do
      it 'sets all_day to true if starting and ending at start and end of day' do
        event_time = EventTime.new(starting: start_date, ending: end_date)
        event_time.save
        expect(event_time.all_day).to be true
      end

      it 'sets all_day to false if not starting and ending at start and end of day' do
        event_time = EventTime.new(starting: start_date + 1.hour, ending: end_date - 1.hour)
        event_time.save
        expect(event_time.all_day).to be false
      end
    end
  end
end