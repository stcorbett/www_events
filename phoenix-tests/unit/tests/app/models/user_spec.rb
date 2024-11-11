require 'rails_helper'

RSpec.describe User, type: :model do
  # Associations
  it { should have_many(:events) }

  # Store
  it { should store_accessor(:hearts) }

  describe '.create_or_authorize' do
    let(:auth) do
      OpenStruct.new(
        provider: 'test_provider',
        uid: '12345',
        info: OpenStruct.new(
          name: 'Test User',
          email: 'test@example.com',
          image: 'test_image_url'
        ),
        credentials: OpenStruct.new(
          token: 'test_token',
          expires_at: Time.now.to_i
        )
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
          provider: auth.provider,
          uid: auth.uid,
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
        expect(user.image).to eq('test_image_url')
        expect(user.token).to eq('test_token')
      end
    end
  end

  describe '#editable_events' do
    let(:user) { User.create!(email: 'test@example.com') }
    let(:event) { Event.create!(user: user, title: 'Test Event') }

    before do
      allow(Event).to receive_message_chain(:configured_year, :joins, :where).and_return([event])
    end

    it 'returns events for the user' do
      expect(user.editable_events).to include(event)
    end
  end

  describe '#heart_for?' do
    let(:user) { User.create!(hearts: { LakesOfFireConfig.year => [1, 2, 3] }) }
    let(:event_time) { double('EventTime', id: 2) }

    it 'returns true if the event_time is in hearts' do
      expect(user.heart_for?(event_time)).to be true
    end

    it 'returns false if the event_time is not in hearts' do
      allow(event_time).to receive(:id).and_return(4)
      expect(user.heart_for?(event_time)).to be false
    end

    it 'returns nil if the argument is not an EventTime' do
      expect(user.heart_for?(double('NotEventTime'))).to be_nil
    end
  end

  describe '#add_heart' do
    let(:user) { User.create!(hearts: { LakesOfFireConfig.year => [1, 2] }) }
    let(:event_time) { double('EventTime', id: 3) }

    it 'adds the event_time id to hearts' do
      user.add_heart(event_time)
      expect(user.hearts[LakesOfFireConfig.year]).to include(3)
    end

    it 'does not add duplicate event_time id' do
      allow(event_time).to receive(:id).and_return(2)
      user.add_heart(event_time)
      expect(user.hearts[LakesOfFireConfig.year].count(2)).to eq(1)
    end
  end

  describe '#remove_heart' do
    let(:user) { User.create!(hearts: { LakesOfFireConfig.year => [1, 2, 3] }) }
    let(:event_time) { double('EventTime', id: 2) }

    it 'removes the event_time id from hearts' do
      user.remove_heart(event_time)
      expect(user.hearts[LakesOfFireConfig.year]).not_to include(2)
    end

    it 'does nothing if the event_time id is not in hearts' do
      allow(event_time).to receive(:id).and_return(4)
      expect {
        user.remove_heart(event_time)
      }.not_to change { user.hearts[LakesOfFireConfig.year] }
    end
  end
end