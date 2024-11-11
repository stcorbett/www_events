require 'rails_helper'

RSpec.describe HostedFile, type: :model do
  # Test for database columns
  it { should have_db_column(:name).of_type(:string) }
  it { should have_db_column(:content).of_type(:text) }
  it { should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
  it { should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }

  # Test for validations
  # Assuming there might be validations, though not present in the provided code
  # Uncomment and modify these lines if validations are added in the future
  # it { should validate_presence_of(:name) }
  # it { should validate_presence_of(:content) }

  describe 'instance methods' do
    let(:hosted_file) { HostedFile.create(name: 'Test File', content: 'This is a test file content.') }

    context 'when accessing attributes' do
      it 'returns the correct name' do
        expect(hosted_file.name).to eq('Test File')
      end

      it 'returns the correct content' do
        expect(hosted_file.content).to eq('This is a test file content.')
      end
    end
  end

  describe 'scopes' do
    # Assuming there might be scopes, though not present in the provided code
    # Uncomment and modify these lines if scopes are added in the future
    # describe '.recent' do
    #   it 'returns files ordered by created_at descending' do
    #     old_file = HostedFile.create(name: 'Old File', content: 'Old content', created_at: 1.day.ago)
    #     new_file = HostedFile.create(name: 'New File', content: 'New content', created_at: 1.hour.ago)
    #     expect(HostedFile.recent).to eq([new_file, old_file])
    #   end
    # end
  end
end