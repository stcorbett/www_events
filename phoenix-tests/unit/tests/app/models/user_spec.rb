require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:events) }
  end

  describe '.create_or_authorize' do
    let(:auth) do
      double(
        provider: 'provider_name',
        uid: '12345',
        info: double(name: 'Test User', email: 'test@example.com', image: 'image_url'),
        credentials: double(token: 'token123', expires_at: Time.now.to_i)
      )
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          User.create_or_authorize(auth)
        }.to change(User, :count).by(1)
      end
    end

    context 'when user already exists' do
      before do
        User.create!(
          provider: 'provider_name',
          uid: '12345',
          name: 'Existing User',
          email: 'existing@example.com',
          image: 'existing_image_url',
          token: 'existing_token',
          expires_at: Time.now
        )
      end

      it 'does not create a new user' do
        expect {
          User.create_or_authorize(auth)
        }.not_to change(User, :count)
      end

      it 'updates the existing user' do
        user = User.create_or_authorize(auth)
        expect(user.name).to eq('Test User')
        expect(user.email).to eq('test@example.com')
        expect(user.image).to eq('image_url')
        expect(user.token).to eq('token123')
      end
    end
  end

  describe '#editable_events' do
    let(:user) { User.create!(email: 'test@example.com') }
    let(:event) { Event.create!(user_id: user.id, title: 'Test Event') }

    before do
      allow(Event).to receive(:configured_year).and_return(Event.all)
    end

    it 'returns events for the user' do
      expect(user.editable_events).to include(event)
    end
  end

  describe '#heart_for?' do
    let(:user) { User.create!(hearts: { LakesOfFireConfig.year => [1] }.to_json) }
    let(:event_time) { double(id: 1) }

    it 'returns true if the event_time is hearted' do
      allow(event_time).to receive(:is_a?).with(EventTime).and_return(true)
      expect(user.heart_for?(event_time)).to be true
    end

    it 'returns false if the event_time is not hearted' do
      allow(event_time).to receive(:is_a?).with(EventTime).and_return(true)
      allow(event_time).to receive(:id).and_return(2)
      expect(user.heart_for?(event_time)).to be false
    end

    it 'returns nil if the argument is not an EventTime' do
      expect(user.heart_for?(double)).to be_nil
    end
  end

  describe '#add_heart' do
    let(:user) { User.create!(hearts: {}.to_json) }
    let(:event_time) { double(id: 1) }

    before do
      allow(event_time).to receive(:is_a?).with(EventTime).and_return(true)
    end

    it 'adds a heart for the event_time' do
      user.add_heart(event_time)
      expect(user.hearts[LakesOfFireConfig.year]).to include(event_time.id)
    end

    it 'does not add a heart if already hearted' do
      user.add_heart(event_time)
      expect {
        user.add_heart(event_time)
      }.not_to change { user.hearts[LakesOfFireConfig.year].size }
    end
  end

  describe '#remove_heart' do
    let(:user) { User.create!(hearts: { LakesOfFireConfig.year => [1] }.to_json) }
    let(:event_time) { double(id: 1) }

    before do
      allow(event_time).to receive(:is_a?).with(EventTime).and_return(true)
    end

    it 'removes a heart for the event_time' do
      user.remove_heart(event_time)
      expect(user.hearts[LakesOfFireConfig.year]).not_to include(event_time.id)
    end

    it 'does nothing if the event_time is not hearted' do
      allow(event_time).to receive(:id).and_return(2)
      expect {
        user.remove_heart(event_time)
      }.not_to change { user.hearts[LakesOfFireConfig.year].size }
    end
  end
end