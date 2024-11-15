require 'rails_helper'

RSpec.describe Event, type: :model do
  # Associations
  it { should belong_to(:user) }
  it { should have_many(:event_times).dependent(:destroy) }

  # Validations
  it { should validate_presence_of(:hosting_location) }
  it { should validate_presence_of(:main_contact_person) }
  it { should validate_presence_of(:contact_person_email) }
  it { should validate_presence_of(:event_recurrence) }
  it { should validate_presence_of(:event_description) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:title) }
  it { should validate_length_of(:event_description).is_at_most(20000) }

  describe 'custom validations' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.new(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Weekly', event_description: 'Description', title: 'Title') }

    it 'validates presence of event_times' do
      event.valid?
      expect(event.errors[:event_times]).to include("are needed")
    end
  end

  describe '.configured_year' do
    let!(:event) { Event.create!(created_at: Date.new(LakesOfFireConfig.year, 1, 2), user: User.create!(name: 'Test User', email: 'test@example.com'), hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Weekly', event_description: 'Description', title: 'Title', event_times: [EventTime.new(starting: Time.zone.now, ending: Time.zone.now + 1.hour)]) }

    it 'returns events created after the start of the configured year' do
      expect(Event.configured_year).to include(event)
    end
  end

  describe '.sorted_by_date' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Weekly', event_description: 'Description', title: 'Title', event_times: [event_time]) }
    let!(:event_time) { EventTime.create!(event: event, starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

    it 'returns events sorted by date' do
      sorted_events = Event.sorted_by_date
      expect(sorted_events.first.current_event_time).to eq(event_time)
    end
  end

  describe '.lakes_of_fire_event_hash' do
    it 'returns a hash of events for each day' do
      expect(Event.lakes_of_fire_event_hash.keys).to match_array(["Wednesday", "Thursday", "Friday", "Saturday", "Sunday"])
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
    let(:event) { Event.new(fire_art: true, alcohol: false, red_light: true, spectacle: false, food: true, crafting: false, sober: true) }

    it 'returns an array of active categories' do
      expect(event.categories).to match_array([:fire_art, :red_light, :food, :sober])
    end
  end

  describe '#single_event_time' do
    let(:event) { Event.create!(user: User.create!(name: 'Test User', email: 'test@example.com'), hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Weekly', event_description: 'Description', title: 'Title', event_times: [event_time]) }
    let!(:event_time) { EventTime.create!(event: event, starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

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
    let(:event) { Event.new(title: 'Title', hosting_location: 'Location', site_id: '123', event_description: 'Description', fire_art: true, alcohol: false, red_light: true, food: true, crafting: false, sober: true, spectacle: false) }
    let(:event_time) { EventTime.new(starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

    before do
      event.current_event_time = event_time
    end

    it 'returns a hash representation of the event' do
      expect(event.lakes_of_fire_hash).to include("Title" => 'Title', "Location" => 'Location', "SiteId" => '123', "Description" => 'Description', "FireArt" => true, "Alcohol" => false, "Explicit" => true, "Food" => true, "Craft" => false, "Sober" => true, "Spectacle" => false)
    end
  end

  describe '#human_location' do
    let(:event) { Event.new(hosting_location: 'Location', site_id: '123') }

    it 'returns a human-readable location' do
      expect(event.human_location).to eq('Location | Site 123')
    end
  end

  describe '#event_time_error_messages' do
    let(:event) { Event.create!(user: User.create!(name: 'Test User', email: 'test@example.com'), hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Weekly', event_description: 'Description', title: 'Title', event_times: [event_time]) }
    let!(:event_time) { EventTime.create!(event: event, starting: Time.zone.now, ending: Time.zone.now + 1.hour, all_day: false) }

    it 'returns error messages for event times' do
      event_time.errors.add(:base, 'Error message')
      expect(event.event_time_error_messages).to include('Error message')
    end
  end

  describe '#category_emojis' do
    let(:event) { Event.new(fire_art: true, alcohol: false, red_light: true, spectacle: false, food: true, crafting: false, sober: true) }

    it 'returns a hash of active category emojis' do
      expect(event.category_emojis).to eq({ fire_art: '🔥', red_light: '🔴', food: '🍽', sober: '⚖️' })
    end
  end
end
