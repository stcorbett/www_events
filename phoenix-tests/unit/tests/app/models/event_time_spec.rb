require 'rails_helper'

RSpec.describe EventTime, type: :model do
  include ActionView::Helpers::DateHelper

  # Mocking LakesOfFireConfig
  before do
    allow(LakesOfFireConfig).to receive(:start_date).and_return(Date.new(2023, 6, 1))
    allow(LakesOfFireConfig).to receive(:start_time).and_return(Time.zone.local(2023, 6, 1, 8, 0))
    allow(LakesOfFireConfig).to receive(:end_time).and_return(Time.zone.local(2023, 6, 5, 20, 0))
    allow(LakesOfFireConfig).to receive(:event_days).and_return({
      sunday: Date.new(2023, 6, 4),
      monday: Date.new(2023, 6, 5)
    })
  end

  describe 'associations' do
    it { should belong_to(:event) }
  end

  describe 'validations' do
    it { should validate_presence_of(:starting) }
    it { should validate_presence_of(:ending) }

    context 'custom validations' do
      let(:event) { Event.create!(title: 'Test Event') }

      it 'validates starting and ending are within Lakes of Fire dates' do
        event_time = EventTime.new(event: event, starting: Time.zone.local(2023, 5, 31, 10, 0), ending: Time.zone.local(2023, 6, 1, 10, 0))
        expect(event_time).not_to be_valid
        expect(event_time.errors[:starting]).to include("Can't start before Lakes of Fire Starts!")

        event_time.starting = Time.zone.local(2023, 6, 1, 10, 0)
        event_time.ending = Time.zone.local(2023, 6, 6, 10, 0)
        expect(event_time).not_to be_valid
        expect(event_time.errors[:ending]).to include("Can't end after Lakes of Fire Ends!")
      end
    end
  end

  describe 'scopes' do
    let(:event) { Event.create!(title: 'Test Event') }

    it 'returns events after the configured year start date' do
      event_time1 = EventTime.create!(event: event, starting: Time.zone.local(2023, 6, 2, 10, 0), ending: Time.zone.local(2023, 6, 2, 12, 0))
      event_time2 = EventTime.create!(event: event, starting: Time.zone.local(2023, 5, 30, 10, 0), ending: Time.zone.local(2023, 5, 30, 12, 0))

      expect(EventTime.configured_year).to include(event_time1)
      expect(EventTime.configured_year).not_to include(event_time2)
    end
  end

  describe 'instance methods' do
    let(:event) { Event.create!(title: 'Test Event') }
    let(:event_time) { EventTime.create!(event: event, starting: Time.zone.local(2023, 6, 2, 10, 0), ending: Time.zone.local(2023, 6, 2, 12, 0)) }

    describe '#start_date' do
      it 'returns formatted start date' do
        expect(event_time.start_date).to eq('06-02-2023')
      end
    end

    describe '#start_time' do
      it 'returns formatted start time' do
        expect(event_time.start_time).to eq('10:00AM')
      end
    end

    describe '#end_date' do
      it 'returns formatted end date' do
        expect(event_time.end_date).to eq('06-02-2023')
      end
    end

    describe '#end_time' do
      it 'returns formatted end time' do
        expect(event_time.end_time).to eq('12:00PM')
      end
    end

    describe '#abbr_day' do
      it 'returns abbreviated day of the week' do
        expect(event_time.abbr_day).to eq('F')
      end
    end

    describe '#duration_human' do
      it 'returns human-readable duration' do
        expect(event_time.duration_human).to eq('2 hours')
      end
    end

    describe '#human_time' do
      it 'returns human-readable time' do
        expect(event_time.human_time).to eq('10:00 AM | 2 hours')
      end

      it 'returns "All Day" if all_day is true' do
        allow(event_time).to receive(:all_day).and_return(true)
        expect(event_time.human_time).to eq('All Day')
      end
    end

    describe '#day_of_event_index' do
      it 'returns the index of the day of the event' do
        allow(event_time).to receive(:day_of_week).and_return('sunday')
        expect(event_time.day_of_event_index).to eq(0)
      end
    end

    describe '#day_of_event' do
      it 'returns the date of the event' do
        allow(event_time).to receive(:day_of_week).and_return('sunday')
        expect(event_time.day_of_event).to eq(Date.new(2023, 6, 4))
      end
    end

    describe '#starting_at_start_of_day?' do
      it 'returns true if starting is at the start of the day' do
        allow(event_time).to receive(:day_of_event).and_return(Date.new(2023, 6, 2))
        allow(LakesOfFireConfig).to receive(:start_time).and_return(Time.zone.local(2023, 6, 2, 0, 0))
        event_time.starting = Time.zone.local(2023, 6, 2, 0, 0)
        expect(event_time.starting_at_start_of_day?).to be true
      end
    end

    describe '#ending_at_end_of_day?' do
      it 'returns true if ending is at the end of the day' do
        allow(event_time).to receive(:day_of_event).and_return(Date.new(2023, 6, 2))
        allow(LakesOfFireConfig).to receive(:end_time).and_return(Time.zone.local(2023, 6, 2, 23, 59))
        event_time.ending = Time.zone.local(2023, 6, 2, 23, 59)
        expect(event_time.ending_at_end_of_day?).to be true
      end
    end
  end

  describe 'callbacks' do
    let(:event) { Event.create!(title: 'Test Event') }

    it 'sets all_day flag before save' do
      event_time = EventTime.new(event: event, starting: Time.zone.local(2023, 6, 2, 0, 0), ending: Time.zone.local(2023, 6, 2, 23, 59))
      event_time.save
      expect(event_time.all_day).to be true
    end
  end
end