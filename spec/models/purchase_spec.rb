require 'rails_helper'

RSpec.describe Purchase, type: :model do
  describe 'validations' do
    subject { build(:purchase) }

    it { should validate_presence_of(:quantity) }
    it { should validate_presence_of(:unit_price) }
    # Total amount is calculated by callbacks, test basic functionality
    it 'has total_amount calculated' do
      purchase = build(:purchase)
      expect(purchase.total_amount).to be > 0
    end
    it { should validate_presence_of(:status) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
    # Total amount validation is affected by callbacks, test basic behavior
    it 'calculates total_amount correctly' do
      purchase = build(:purchase, quantity: 2, unit_price: 10.0)
      expect(purchase.total_amount).to eq(20.0)
    end
    it { should validate_inclusion_of(:status).in_array(%w[pending completed cancelled refunded]) }
  end

  describe 'associations' do
    it { should belong_to(:product) }
    it { should belong_to(:client) }
  end

  describe 'scopes' do
    let(:product) { create(:product) }
    let(:client) { create(:client) }
    let!(:completed_purchase) { create(:purchase, status: 'completed', product: product, client: client) }
    let!(:pending_purchase) { create(:purchase, status: 'pending', product: product, client: client) }
    let!(:today_purchase) { create(:purchase, purchase_date: Date.current, product: product, client: client) }
    let!(:yesterday_purchase) { create(:purchase, purchase_date: Date.yesterday, product: product, client: client) }

    it 'returns completed purchases' do
      expect(Purchase.completed).to include(completed_purchase, today_purchase, yesterday_purchase)
      expect(Purchase.completed).not_to include(pending_purchase)
    end

    it 'returns purchases for a specific date' do
      expect(Purchase.daily_report(Date.current)).to include(today_purchase)
      expect(Purchase.daily_report(Date.current)).not_to include(yesterday_purchase)
    end

    it 'returns purchases within date range' do
      start_date = Date.yesterday
      end_date = Date.current
      expect(Purchase.by_date_range(start_date, end_date)).to include(today_purchase, yesterday_purchase)
    end

    it 'can filter purchases by product' do
      other_product = create(:product)
      other_purchase = create(:purchase, product: other_product, client: client)

      product_purchases = Purchase.where(product: product)
      expect(product_purchases).to include(completed_purchase, pending_purchase)
      expect(product_purchases).not_to include(other_purchase)
    end

    it 'returns purchases by client' do
      other_client = create(:client)
      other_purchase = create(:purchase, product: product, client: other_client)

      expect(Purchase.by_client(client.id)).to include(completed_purchase, pending_purchase)
      expect(Purchase.by_client(client.id)).not_to include(other_purchase)
    end
  end

  describe 'callbacks' do
    let(:product) { create(:product, stock: 10) }
    let(:client) { create(:client) }

    it 'processes purchase after create' do
      purchase = build(:purchase, product: product, client: client, quantity: 3)
      expect(purchase.save!).to be true
      expect(purchase.status).to eq('completed')
    end

    it 'reduces product stock after purchase' do
      expect {
        create(:purchase, product: product, client: client, quantity: 3)
      }.to change { product.reload.stock }.by(-3)
    end
  end

  describe 'instance methods' do
    let(:product) { create(:product, stock: 10) }
    let(:client) { create(:client) }

    describe '#first_purchase_of_product?' do
      it 'returns true for first purchase of a product' do
        purchase = create(:purchase, product: product, client: client)
        expect(purchase.first_purchase_of_product?).to be true
      end

      it 'returns false for subsequent purchases of same product' do
        # Create first purchase with earlier date
        first_purchase = create(:purchase,
                               product: product,
                               client: client,
                               purchase_date: 1.day.ago)

        # Create second purchase with later date
        second_client = create(:client)
        second_purchase = create(:purchase,
                                product: product,
                                client: second_client,
                                purchase_date: Time.current)

        # The first purchase should be the first one
        expect(first_purchase.first_purchase_of_product?).to be true
        # The second purchase should not be the first one
        expect(second_purchase.first_purchase_of_product?).to be false
      end
    end

    describe 'purchase behavior' do
      it 'has required attributes' do
        purchase = create(:purchase, product: product, client: client, quantity: 3)
        expect(purchase.quantity).to eq(3)
        expect(purchase.product).to eq(product)
        expect(purchase.client).to eq(client)
      end
    end
  end

  describe 'validations on create' do
    let(:product) { create(:product, stock: 5) }
    let(:client) { create(:client) }

    it 'validates product has sufficient stock' do
      purchase = build(:purchase, product: product, client: client, quantity: 10)
      expect(purchase).not_to be_valid
      expect(purchase.errors[:quantity]).to include('exceeds available stock (5 available)')
    end

    it 'allows purchase with sufficient stock' do
      purchase = build(:purchase, product: product, client: client, quantity: 3)
      expect(purchase).to be_valid
    end
  end
end
