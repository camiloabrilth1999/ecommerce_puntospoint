require 'rails_helper'

RSpec.describe Administrator, type: :model do
  describe 'validations' do
    subject { build(:administrator) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_inclusion_of(:role).in_array(%w[admin manager]) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
  end

  describe 'associations' do
    it { should have_many(:products).dependent(:restrict_with_error) }
    it { should have_many(:versions).class_name('PaperTrail::Version') }
  end

  describe 'scopes' do
    let!(:active_admin) { create(:administrator, active: true) }
    let!(:inactive_admin) { create(:administrator, active: false) }
    let!(:admin_role) { create(:administrator, role: 'admin') }
    let!(:manager_role) { create(:administrator, role: 'manager') }

    it 'returns active administrators' do
      expect(Administrator.active).to include(active_admin, admin_role, manager_role)
      expect(Administrator.active).not_to include(inactive_admin)
    end

    it 'returns administrators with admin role' do
      expect(Administrator.admins).to include(admin_role)
      expect(Administrator.admins).not_to include(manager_role)
    end

    it 'returns administrators with manager role' do
      expect(Administrator.managers).to include(manager_role)
      expect(Administrator.managers).not_to include(admin_role)
    end
  end

  describe 'instance methods' do
    let(:administrator) { create(:administrator) }

    it 'has secure password' do
      expect(administrator).to respond_to(:authenticate)
    end

    it 'normalizes email before validation' do
      administrator.email = '  TEST@Example.COM  '
      administrator.valid?
      expect(administrator.email).to eq('test@example.com')
    end
  end

  describe 'paper trail' do
    it 'has paper trail enabled' do
      administrator = create(:administrator)
      administrator.update!(name: 'Updated Name')
      expect(administrator.versions.count).to be > 0
    end
  end
end
