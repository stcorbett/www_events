require 'rails_helper'

RSpec.describe Event, type: :model do
  # Associations
  it { should belong_to(:user) }
  it { should have_many(:event_times).dependent(:destroy) }
  it { should have_one(:single_event_time) }

  # Validations
  it { should validate_presence_of(:hosting_location) }
  it { should validate_presence_of(:main_contact_person) }
  it { should validate_presence_of(:contact_person_email) }
  it { should validate_presence_of(:event_recurrence) }
  it { should validate_presence_of(:event_description) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:title) }
  it { should validate_length_of(:event_description).is_at_most(20000) }
  it { should validate_associated(:event_times) }

  describe 'custom validations' do
    context 'when event_times are empty' do
      let(:event) { Event.new(event_times: []) }

      it 'adds an error on event_times' do
        event.valid?
        expect(event.errors[:event_times]).to include("are needed")
      end
    end
  end

  describe '.sorted_by_date' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'email@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }
    let!(:event_time) { event.event_times.create!(starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

    it 'returns events sorted by date' do
      expect(Event.sorted_by_date).to include(event)
    end

    it 'filters events by specific date' do
      specific_date = Date.today
      expect(Event.sorted_by_date(specific_date)).to include(event)
    end
  end

  describe '.lakes_of_fire_event_hash' do
    it 'returns a hash of events for each day' do
      expect(Event.lakes_of_fire_event_hash.keys).to contain_exactly('Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
    end
  end

  describe '.category_emojis' do
    it 'returns a hash of category emojis' do
      expect(Event.category_emojis).to eq({
        fire_art: '🔥',
        alcohol: '🍻',
        red_light: '🔴',
        spectacle: '👓',
        food: '🍽',
        crafting: '🎨',
        sober: '⚖️'
      })
    end
  end

  describe '#categories' do
    let(:event) { Event.new(fire_art: true, alcohol: false, red_light: true) }

    it 'returns an array of active categories' do
      expect(event.categories).to contain_exactly(:fire_art, :red_light)
    end
  end

  describe '#single_event_time' do
    let(:event) { Event.new }
    let(:event_time) { EventTime.new }

    before { event.event_times << event_time }

    it 'returns the first event time' do
      expect(event.single_event_time).to eq([event_time])
    end
  end

  describe '#build_empty_event_times' do
    let(:event) { Event.new }

    it 'builds empty event times for each day' do
      event.build_empty_event_times
      expect(event.event_times.size).to eq(LakesOfFireConfig.event_day_names.size)
    end
  end

  describe '#event_description=' do
    let(:event) { Event.new }

    it 'replaces special characters in the description' do
      event.event_description = "“Test” − – —"
      expect(event.event_description).to eq('"Test" - - -')
    end
  end

  describe '#site_id=' do
    let(:event) { Event.new }

    it 'sets site_id to nil if blank' do
      event.site_id = ''
      expect(event.site_id).to be_nil
    end
  end

  describe '#lakes_of_fire_hash' do
    let(:event) { Event.new(title: 'Title', hosting_location: 'Location') }
    let(:event_time) { EventTime.new(starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

    before { event.current_event_time = event_time }

    it 'returns a hash representation of the event' do
      expect(event.lakes_of_fire_hash).to include("Title" => 'Title', "Location" => 'Location')
    end
  end

  describe '#human_location' do
    let(:event) { Event.new(hosting_location: 'Location', site_id: '123') }

    it 'returns a formatted location string' do
      expect(event.human_location).to eq('Location | Site 123')
    end
  end

  describe '#event_time_error_messages' do
    let(:event) { Event.new }
    let(:event_time) { EventTime.new }

    before do
      event.event_times << event_time
      event_time.errors.add(:base, 'Error message')
    end

    it 'returns error messages for event times' do
      expect(event.event_time_error_messages).to include('Error message')
    end
  end

  describe '#category_emojis' do
    let(:event) { Event.new(fire_art: true, alcohol: false, red_light: true) }

    it 'returns emojis for active categories' do
      expect(event.category_emojis).to eq({ fire_art: '🔥', red_light: '🔴' })
    end
  end
end