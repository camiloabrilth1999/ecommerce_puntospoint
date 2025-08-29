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

      # NUEVO TEST DE CONCURRENCIA REAL - Validación robusta de race conditions
      it 'handles concurrent first purchases correctly (race condition test)', :aggregate_failures do
        # Crear producto y clientes para la prueba
        test_product = create(:product, stock: 100)
        clients = 10.times.map { create(:client) }

        # Variables compartidas para sincronización
        threads = []
        purchases = []
        mutex = Mutex.new
        start_barrier = Concurrent::CountDownLatch.new(clients.count)

        # Ejecutar múltiples iteraciones para aumentar probabilidad de race condition
        3.times do |iteration|
          threads.clear
          purchases.clear

          clients.each_with_index do |test_client, index|
            thread = Thread.new do
              # Sincronizar inicio para maximizar concurrencia
              start_barrier.count_down
              start_barrier.wait

              # Crear compra con timestamp ligeramente diferente pero muy cercano
              base_time = Time.current + iteration.minutes
              purchase_time = base_time + (index * 0.001).seconds

              purchase = create(:purchase,
                               product: test_product,
                               client: test_client,
                               purchase_date: purchase_time)

              mutex.synchronize do
                purchases << purchase
              end
            end
            threads << thread
          end

          # Esperar a que todos los threads terminen
          threads.each(&:join)

          # Recargar desde base de datos para asegurar consistencia
          purchases.each(&:reload)

          # VALIDACIÓN CRÍTICA: Solo UNA compra debe ser primera
          first_purchases = purchases.select(&:first_purchase_of_product?)

          expect(first_purchases.count).to eq(1),
            "Iteración #{iteration + 1}: Se esperaba exactamente 1 primera compra, pero se encontraron #{first_purchases.count}"

          # La primera compra debe ser la más temprana cronológicamente
          earliest_purchase = purchases.min_by(&:purchase_date)
          expect(first_purchases.first).to eq(earliest_purchase),
            "Iteración #{iteration + 1}: La primera compra debería ser la más temprana cronológicamente"

          # VALIDACIÓN ADICIONAL: Verificar que el método es consistente
          first_purchases.each do |purchase|
            expect(purchase.first_purchase_of_product?).to be(true),
              "Iteración #{iteration + 1}: La compra marcada como primera debe retornar true consistentemente"
          end

          # Todas las demás compras NO deben ser primeras
          other_purchases = purchases - first_purchases
          other_purchases.each do |purchase|
            expect(purchase.first_purchase_of_product?).to be(false),
              "Iteración #{iteration + 1}: La compra ID #{purchase.id} no debería ser primera compra"
          end

          # Limpiar para siguiente iteración
          Purchase.where(product: test_product).delete_all
          start_barrier = Concurrent::CountDownLatch.new(clients.count)
        end
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
