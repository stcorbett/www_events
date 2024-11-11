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

  describe '#has_event_time' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.new(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }

    it 'adds an error if event_times is empty' do
      event.valid?
      expect(event.errors[:event_times]).to include('are needed')
    end

    it 'does not add an error if event_times is present' do
      event.event_times.build(starting: Time.now, ending: Time.now + 1.hour)
      event.valid?
      expect(event.errors[:event_times]).to be_empty
    end
  end

  describe '.sorted_by_date' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }
    let!(:event_time) { event.event_times.create!(starting: Time.zone.now, ending: Time.zone.now + 1.hour) }

    it 'returns events sorted by date' do
      sorted_events = Event.sorted_by_date
      expect(sorted_events.first.current_event_time).to eq(event_time)
    end

    it 'filters events by specific date' do
      specific_date = Date.today
      sorted_events = Event.sorted_by_date(specific_date)
      expect(sorted_events).to include(event)
    end
  end

  describe '.lakes_of_fire_event_hash' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }
    let!(:event_time) { event.event_times.create!(starting: Time.zone.now, ending: Time.zone.now + 1.hour) }

    before do
      allow(LakesOfFireConfig).to receive(:event_days).and_return({ wednesday: Date.today, thursday: Date.today, friday: Date.today, saturday: Date.today, sunday: Date.today })
    end

    it 'returns a hash of events for each day' do
      hash = Event.lakes_of_fire_event_hash
      expect(hash.keys).to contain_exactly('Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')
    end
  end

  describe '#lakes_of_fire_hash' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }
    let!(:event_time) { event.event_times.create!(starting: Time.zone.now, ending: Time.zone.now + 1.hour) }

    before do
      event.current_event_time = event_time
    end

    it 'returns a hash representation of the event' do
      hash = event.lakes_of_fire_hash
      expect(hash['Title']).to eq(event.title)
      expect(hash['Location']).to eq(event.hosting_location)
      expect(hash['StartTime']).to eq(event_time.starting.in_time_zone)
    end
  end

  describe '#category_emojis' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title', fire_art: true, alcohol: false) }

    it 'returns a hash of category emojis' do
      emojis = event.category_emojis
      expect(emojis).to eq({ fire_art: '🔥' })
    end
  end

  describe '#human_location' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title', site_id: '123') }

    it 'returns a human-readable location with site id' do
      expect(event.human_location).to eq('Location | Site 123')
    end

    it 'returns a human-readable location without site id' do
      event.site_id = nil
      expect(event.human_location).to eq('Location')
    end
  end

  describe '#event_time_error_messages' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }
    let!(:event_time) { event.event_times.create!(starting: Time.zone.now, ending: Time.zone.now + 1.hour) }

    it 'returns error messages for event times' do
      event_time.errors.add(:starting, 'must be present')
      expect(event.event_time_error_messages).to include('Starting must be present')
    end
  end

  describe '#event_description=' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }

    it 'replaces special characters in description' do
      event.event_description = '“Test” − – —'
      expect(event.event_description).to eq('"Test" - - -')
    end
  end

  describe '#site_id=' do
    let(:user) { User.create!(name: 'Test User', email: 'test@example.com') }
    let(:event) { Event.create!(user: user, hosting_location: 'Location', main_contact_person: 'Contact', contact_person_email: 'contact@example.com', event_recurrence: 'Once', event_description: 'Description', title: 'Title') }

    it 'sets site_id to nil if blank' do
      event.site_id = ''
      expect(event.site_id).to be_nil
    end
  end
end