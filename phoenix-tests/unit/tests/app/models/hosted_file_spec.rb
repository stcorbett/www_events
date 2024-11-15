require 'rails_helper'

RSpec.describe HostedFile, type: :model do
  # Assuming HostedFile has no associations or validations to test with shoulda matchers
  # If there were associations or validations, they would be tested here

  describe 'basic functionality' do
    let(:hosted_file) { HostedFile.new }

    it 'can be instantiated' do
      expect(hosted_file).to be_an_instance_of(HostedFile)
    end

    it 'can be saved to the database' do
      hosted_file.save
      expect(hosted_file.persisted?).to be true
    end

    it 'can be destroyed' do
      hosted_file.save
      expect { hosted_file.destroy }.to change { HostedFile.count }.by(-1)
    end
  end
end