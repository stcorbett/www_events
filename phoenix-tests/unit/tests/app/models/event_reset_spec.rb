require 'rails_helper'

RSpec.describe EventReset, type: :model do
  describe '.destroy_all_events' do
    before do
      # Ensure the database is clean before each test
      Event.destroy_all
    end

    context 'when there are events in the database' do
      let!(:event1) { Event.create!(title: 'Event 1') }
      let!(:event2) { Event.create!(title: 'Event 2') }

      it 'destroys all events' do
        expect(Event.count).to eq(2) # Ensure events are created
        EventReset.destroy_all_events
        expect(Event.count).to eq(0) # Ensure all events are destroyed
      end
    end

    context 'when there are no events in the database' do
      it 'does not raise an error and leaves the database empty' do
        expect(Event.count).to eq(0) # Ensure no events exist
        expect { EventReset.destroy_all_events }.not_to raise_error
        expect(Event.count).to eq(0) # Ensure database remains empty
      end
    end
  end
end
