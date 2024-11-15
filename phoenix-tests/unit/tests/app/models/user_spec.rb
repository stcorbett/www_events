require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:events) }
  end

  describe 'store accessors' do
    it 'should store hearts as a hash' do
      user = User.new
      expect(user.hearts).to be_a(Hash)
    end
  end

  describe '.create_or_authorize' do
    let(:auth) do
      double('Auth', 
        provider: 'provider_name', 
        uid: '12345', 
        info: double('Info', name: 'Test User', email: 'test@example.com', image: 'image_url'), 
        credentials: double('Credentials', token: 'token', expires_at: Time.now.to_i)
      )
    end

    it 'creates a new user if one does not exist' do
      allow(auth).to receive(:to_hash).and_return({ "provider" => "provider_name", "uid" => "12345" })
      expect {
        User.create_or_authorize(auth)
      }.to change(User, :count).by(1)
    end

    it 'authorizes an existing user' do
      User.create(provider: 'provider_name', uid: '12345', name: 'Existing User', email: 'existing@example.com')
      allow(auth).to receive(:to_hash).and_return({ "provider" => "provider_name", "uid" => "12345" })
      expect {
        User.create_or_authorize(auth)
      }.not_to change(User, :count)
    end
  end

  describe '#editable_events' do
    let(:user) { User.create(email: 'test@example.com') }
    let!(:event) { Event.create(year: LakesOfFireConfig.year, user: user) }

    it 'returns events for the configured year and user email' do
      allow(Event).to receive(:configured_year).and_return(Event.where(year: LakesOfFireConfig.year))
      expect(user.editable_events).to include(event)
    end
  end

  describe '#heart_for?' do
    let(:user) { User.new }
    let(:event_time) { double('EventTime', id: 1) }

    before do
      allow(LakesOfFireConfig).to receive(:year).and_return('2023')
    end

    it 'returns true if the event_time is in hearts for the current year' do
      user.hearts['2023'] = [1]
      expect(user.heart_for?(event_time)).to be true
    end

    it 'returns false if the event_time is not in hearts for the current year' do
      user.hearts['2023'] = []
      expect(user.heart_for?(event_time)).to be false
    end
  end

  describe '#add_heart' do
    let(:user) { User.new }
    let(:event_time) { double('EventTime', id: 1) }

    before do
      allow(LakesOfFireConfig).to receive(:year).and_return('2023')
    end

    it 'adds the event_time id to hearts for the current year' do
      user.add_heart(event_time)
      expect(user.hearts['2023']).to include(1)
    end

    it 'does not add the event_time id if it already exists' do
      user.hearts['2023'] = [1]
      user.add_heart(event_time)
      expect(user.hearts['2023'].count(1)).to eq(1)
    end
  end

  describe '#remove_heart' do
    let(:user) { User.new }
    let(:event_time) { double('EventTime', id: 1) }

    before do
      allow(LakesOfFireConfig).to receive(:year).and_return('2023')
      user.hearts['2023'] = [1]
    end

    it 'removes the event_time id from hearts for the current year' do
      user.remove_heart(event_time)
      expect(user.hearts['2023']).not_to include(1)
    end

    it 'does nothing if the event_time id is not in hearts' do
      user.hearts['2023'] = []
      user.remove_heart(event_time)
      expect(user.hearts['2023']).to be_empty
    end
  end
end
