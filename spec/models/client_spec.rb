require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
  end

  describe 'associations' do
    it { should have_many(:purchases).dependent(:restrict_with_error) }
    it { should have_many(:products).through(:purchases) }
  end

  describe 'scopes' do
    let!(:active_client) { create(:client, active: true) }
    let!(:inactive_client) { create(:client, active: false) }

    it 'returns active clients' do
      expect(Client.active).to include(active_client)
      expect(Client.active).not_to include(inactive_client)
    end
  end

  describe 'instance methods' do
    let(:client) { create(:client) }

    it 'has basic attributes accessible' do
      expect(client.name).to be_present
      expect(client.email).to be_present
    end
  end
end
