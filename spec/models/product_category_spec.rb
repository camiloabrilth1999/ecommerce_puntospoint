require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:category) }
  end

  describe 'validations' do
    let(:product) { create(:product) }
    let(:category) { create(:category) }

    it 'validates uniqueness of product_id scoped to category_id' do
      create(:product_category, product: product, category: category)
      duplicate = build(:product_category, product: product, category: category)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:product_id]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    let(:active_product) { create(:product, active: true) }
    let(:inactive_product) { create(:product, active: false) }
    let(:active_category) { create(:category, name: 'Active Category', active: true) }
    let(:inactive_category) { create(:category, name: 'Inactive Category', active: false) }

    let!(:active_product_category) { create(:product_category, product: active_product, category: active_category) }
    let!(:inactive_product_category) { create(:product_category, product: inactive_product, category: active_category) }
    let!(:inactive_category_relation) { create(:product_category, product: active_product, category: inactive_category) }

    it 'returns relations with active products' do
      expect(ProductCategory.active_products).to include(active_product_category)
      expect(ProductCategory.active_products).not_to include(inactive_product_category)
    end

    it 'returns relations with active categories' do
      expect(ProductCategory.active_categories).to include(active_product_category)
      expect(ProductCategory.active_categories).not_to include(inactive_category_relation)
    end
  end
end
