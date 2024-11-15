require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:event1) { double('Event', hosting_location: 'Location A', site_id: 1, title: 'Event 1', human_location: 'Human Location A') }
  let(:event2) { double('Event', hosting_location: 'Location A', site_id: 1, title: 'Event 2', human_location: 'Human Location A') }
  let(:event3) { double('Event', hosting_location: 'Location B', site_id: 2, title: 'Event 3', human_location: 'Human Location B') }

  before do
    allow(Event).to receive_message_chain(:configured_year, :order, :pluck).and_return([
      ['Location A', 1],
      ['Location B', 2]
    ])
    allow(Event).to receive_message_chain(:configured_year, :order, :uniq, :pluck).and_return(['Location A', 'Location B'])
    allow(Event).to receive_message_chain(:configured_year, :where, :order).and_return([event1, event2])
  end

  describe '.all' do
    it 'returns all unique locations with site_ids' do
      locations = Location.all
      expect(locations.size).to eq(2)
      expect(locations.first.hosting_location).to eq('Location A')
      expect(locations.first.site_id).to eq(1)
    end
  end

  describe '.all_locations' do
    it 'returns all unique hosting locations' do
      locations = Location.all_locations
      expect(locations).to eq(['Location A', 'Location B'])
    end
  end

  describe '#update_event_attributes' do
    let(:location) { Location.new('Location A', 1) }
    let(:event_params) { { hosting_location: 'New Location A', site_id: 1 } }

    context 'when event_params are valid' do
      it 'updates the events and hosting_location' do
        allow(event1).to receive(:update!)
        allow(event2).to receive(:update!)

        expect(event1).to receive(:update!).with(event_params)
        expect(event2).to receive(:update!).with(event_params)

        location.update_event_attributes(event_params)
        expect(location.hosting_location).to eq('New Location A')
      end
    end

    context 'when event_params are missing hosting_location' do
      it 'raises an error' do
        expect {
          location.update_event_attributes(site_id: 1)
        }.to raise_error("can't update events without hosting_location")
      end
    end

    context 'when event_params are missing site_id' do
      it 'raises an error' do
        expect {
          location.update_event_attributes(hosting_location: 'New Location A')
        }.to raise_error("can't update events without site_id")
      end
    end
  end

  describe '#events' do
    let(:location) { Location.new('Location A', 1) }

    it 'returns events for the location' do
      events = location.events
      expect(events).to eq([event1, event2])
    end
  end

  describe '#human_location' do
    let(:location) { Location.new('Location A', 1) }

    it 'returns the human location of the first event' do
      expect(location.human_location).to eq('Human Location A')
    end
  end

  describe '#hex_tag' do
    let(:location) { Location.new('Location A', 1) }

    it 'returns a SHA1 hex digest of the hosting location' do
      expect(location.hex_tag).to eq(Digest::SHA1.hexdigest('Location A'))
    end
  end
end