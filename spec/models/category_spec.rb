require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    subject { build(:category) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
  end

  describe 'associations' do
    it { should have_many(:product_categories).dependent(:destroy) }
    it { should have_many(:products).through(:product_categories) }
  end

  describe 'scopes' do
    let!(:active_category) { create(:category, active: true) }
    let!(:inactive_category) { create(:category, active: false) }

    it 'returns active categories' do
      expect(Category.active).to include(active_category)
      expect(Category.active).not_to include(inactive_category)
    end
  end

  describe 'paper trail' do
    it 'has paper trail enabled' do
      category = create(:category)
      category.update!(name: 'Updated Category')
      expect(category.versions.count).to be > 0
    end
  end
end
