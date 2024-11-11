require 'rails_helper'

RSpec.describe HostedFile, type: :model do
  # Assuming the schema provided, we will test the HostedFile model

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:content) }
  end

  describe 'attributes' do
    let(:hosted_file) { HostedFile.new(name: 'Test File', content: 'Sample content') }

    it 'has a name' do
      expect(hosted_file.name).to eq('Test File')
    end

    it 'has content' do
      expect(hosted_file.content).to eq('Sample content')
    end
  end

  describe 'database columns' do
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:content).of_type(:text) }
    it { should have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { should have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'scopes and methods' do
    # Assuming there are no additional methods or scopes in the HostedFile model
    # If there were, we would test them here
  end
end