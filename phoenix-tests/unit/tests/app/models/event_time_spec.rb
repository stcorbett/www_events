require 'rails_helper'
require 'timecop'

RSpec.describe EventTime, type: :model do
  include ActionView::Helpers::DateHelper

  let(:event) { Event.create(name: "Test Event") }
  let(:start_date) { LakesOfFireConfig.start_date }
  let(:end_date) { LakesOfFireConfig.end_date }
  let(:valid_starting) { LakesOfFireConfig.start_time }
  let(:valid_ending) { LakesOfFireConfig.end_time }

  before do
    allow(LakesOfFireConfig).to receive(:start_date).and_return(Date.new(2023, 6, 1))
    allow(LakesOfFireConfig).to receive(:end_date).and_return(Date.new(2023, 6, 5))
    allow(LakesOfFireConfig).to receive(:start_time).and_return(Time.zone.local(2023, 6, 1, 9, 0))
    allow(LakesOfFireConfig).to receive(:end_time).and_return(Time.zone.local(2023, 6, 5, 17, 0))
    allow(LakesOfFireConfig).to receive(:event_days).and_return({
      monday: Date.new(2023, 6, 1),
      tuesday: Date.new(2023, 6, 2),
      wednesday: Date.new(2023, 6, 3),
      thursday: Date.new(2023, 6, 4),
      friday: Date.new(2023, 6, 5)
    })
  end

  it { should belong_to(:event) }
  it { should validate_presence_of(:starting) }
  it { should validate_presence_of(:ending) }

  describe 'validations' do
    context 'when starting before Lakes of Fire starts' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting - 1.day, ending: valid_ending) }

      it 'is not valid' do
        expect(event_time).not_to be_valid
        expect(event_time.errors[:starting]).to include("Can't start before Lakes of Fire Starts!")
      end
    end

    context 'when ending after Lakes of Fire ends' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting, ending: valid_ending + 1.day) }

      it 'is not valid' do
        expect(event_time).not_to be_valid
        expect(event_time.errors[:ending]).to include("Can't end after Lakes of Fire Ends!")
      end
    end
  end

  describe '.start_and_end_from_inputs' do
    it 'calculates correct start and end times' do
      starting, ending = EventTime.start_and_end_from_inputs('monday', '10:00', '11:00')
      expect(starting).to eq(Time.zone.local(2023, 6, 1, 10, 0))
      expect(ending).to eq(Time.zone.local(2023, 6, 1, 11, 0))
    end

    it 'adjusts end time to next day if start time is after end time' do
      starting, ending = EventTime.start_and_end_from_inputs('monday', '23:00', '01:00')
      expect(starting).to eq(Time.zone.local(2023, 6, 1, 23, 0))
      expect(ending).to eq(Time.zone.local(2023, 6, 2, 1, 0))
    end
  end

  describe '#set_all_day_flag' do
    context 'when event is all day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting, ending: valid_ending) }

      it 'sets all_day to true' do
        event_time.save
        expect(event_time.all_day).to be true
      end
    end

    context 'when event is not all day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting + 1.hour, ending: valid_ending - 1.hour) }

      it 'sets all_day to false' do
        event_time.save
        expect(event_time.all_day).to be false
      end
    end
  end

  describe '#duration_human' do
    let(:event_time) { EventTime.new(event: event, starting: valid_starting, ending: valid_starting + 2.hours) }

    it 'returns human-readable duration' do
      expect(event_time.duration_human).to eq('2 hours')
    end
  end

  describe '#human_time' do
    context 'when event is all day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting, ending: valid_ending, all_day: true) }

      it 'returns "All Day"' do
        expect(event_time.human_time).to eq('All Day')
      end
    end

    context 'when event is not all day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting, ending: valid_starting + 2.hours) }

      it 'returns formatted time and duration' do
        expect(event_time.human_time).to eq("#{valid_starting.strftime("%l:%M %p")} | 2 hours")
      end
    end
  end

  describe '#starting_at_start_of_day?' do
    context 'when starting at start of day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting) }

      it 'returns true' do
        expect(event_time.starting_at_start_of_day?).to be true
      end
    end

    context 'when not starting at start of day' do
      let(:event_time) { EventTime.new(event: event, starting: valid_starting + 1.hour) }

      it 'returns false' do
        expect(event_time.starting_at_start_of_day?).to be false
      end
    end
  end

  describe '#ending_at_end_of_day?' do
    context 'when ending at end of day' do
      let(:event_time) { EventTime.new(event: event, ending: valid_ending) }

      it 'returns true' do
        expect(event_time.ending_at_end_of_day?).to be true
      end
    end

    context 'when not ending at end of day' do
      let(:event_time) { EventTime.new(event: event, ending: valid_ending - 1.hour) }

      it 'returns false' do
        expect(event_time.ending_at_end_of_day?).to be false
      end
    end
  end
end
