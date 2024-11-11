require 'rails_helper'

RSpec.describe EventReset, type: :model do
  describe '.destroy_all_events' do
    before do
      # Ensure the database is clean before each test
      Event.destroy_all
    end

    context 'when there are no events' do
      it 'does not raise an error and returns an empty array' do
        expect { EventReset.destroy_all_events }.not_to raise_error
        expect(Event.all).to be_empty
      end
    end

    context 'when there are events' do
      let!(:event1) { Event.create!(title: 'Event 1', hosting_location: 'Location 1') }
      let!(:event2) { Event.create!(title: 'Event 2', hosting_location: 'Location 2') }

      it 'destroys all events' do
        expect(Event.count).to eq(2)
        EventReset.destroy_all_events
        expect(Event.count).to eq(0)
      end
    end

    context 'when an error occurs during destruction' do
      before do
        allow(Event).to receive(:destroy_all).and_raise(ActiveRecord::ActiveRecordError)
      end

      it 'raises an ActiveRecordError' do
        expect { EventReset.destroy_all_events }.to raise_error(ActiveRecord::ActiveRecordError)
      end
    end
  end
end