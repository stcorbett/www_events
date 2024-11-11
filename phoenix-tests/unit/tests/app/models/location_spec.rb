require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:event1) { Event.create!(hosting_location: 'Location A', site_id: '1', title: 'Event 1') }
  let(:event2) { Event.create!(hosting_location: 'Location A', site_id: '1', title: 'Event 2') }
  let(:event3) { Event.create!(hosting_location: 'Location B', site_id: '2', title: 'Event 3') }

  describe '.all' do
    before do
      event1
      event2
      event3
    end

    it 'returns unique Location instances' do
      locations = Location.all
      expect(locations.size).to eq(2)
      expect(locations.map(&:hosting_location)).to contain_exactly('Location A', 'Location B')
    end
  end

  describe '.all_locations' do
    before do
      event1
      event2
      event3
    end

    it 'returns unique hosting locations' do
      locations = Location.all_locations
      expect(locations).to contain_exactly('Location A', 'Location B')
    end
  end

  describe '#update_event_attributes' do
    let(:location) { Location.new('Location A', '1') }

    context 'with valid parameters' do
      let(:event_params) { { hosting_location: 'New Location', site_id: '1' } }

      it 'updates the events and location' do
        location.update_event_attributes(event_params)
        expect(location.hosting_location).to eq('New Location')
        expect(event1.reload.hosting_location).to eq('New Location')
      end
    end

    context 'without hosting_location' do
      let(:event_params) { { site_id: '1' } }

      it 'raises an error' do
        expect { location.update_event_attributes(event_params) }.to raise_error("can't update events without hosting_location")
      end
    end

    context 'without site_id' do
      let(:event_params) { { hosting_location: 'New Location' } }

      it 'raises an error' do
        expect { location.update_event_attributes(event_params) }.to raise_error("can't update events without site_id")
      end
    end
  end

  describe '#events' do
    let(:location) { Location.new('Location A', '1') }

    before do
      event1
      event2
    end

    it 'returns events ordered by title' do
      expect(location.events).to eq([event1, event2])
    end
  end

  describe '#human_location' do
    let(:location) { Location.new('Location A', '1') }

    before do
      event1
    end

    it 'returns the human location of the first event' do
      allow_any_instance_of(Event).to receive(:human_location).and_return('Human Location A')
      expect(location.human_location).to eq('Human Location A')
    end
  end

  describe '#hex_tag' do
    let(:location) { Location.new('Location A', '1') }

    it 'returns a SHA1 hex digest of the hosting location' do
      expect(location.hex_tag).to eq(Digest::SHA1.hexdigest('Location A'))
    end
  end
end