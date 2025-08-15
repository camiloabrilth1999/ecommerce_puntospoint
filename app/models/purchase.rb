class Purchase < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :client

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :purchase_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending completed cancelled refunded] }

  # Business validations
  validate :product_has_sufficient_stock, on: :create

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :by_date_range, ->(start_date, end_date) { where(purchase_date: start_date..end_date) }
  scope :by_category, ->(category_id) { joins(product: :categories).where(categories: { id: category_id }) }
  scope :by_client, ->(client_id) { where(client_id: client_id) }
  scope :by_administrator, ->(admin_id) { joins(:product).where(products: { administrator_id: admin_id }) }
  scope :recent, -> { order(purchase_date: :desc) }

  # Callbacks
  before_validation :set_purchase_date, if: -> { purchase_date.blank? }
  before_validation :calculate_total_amount
  after_create :process_purchase_completion

  # Class methods
  def self.daily_report(date = Date.current)
    where(purchase_date: date.beginning_of_day..date.end_of_day)
      .completed
      .includes(:product, :client)
  end

  def self.group_by_granularity(granularity, start_date, end_date)
    purchases = by_date_range(start_date, end_date).completed

    case granularity
    when "hour"
      purchases.group_by_hour(:purchase_date).count
    when "day"
      purchases.group_by_day(:purchase_date).count
    when "week"
      purchases.group_by_week(:purchase_date).count
    when "year"
      purchases.group_by_year(:purchase_date).count
    else
      {}
    end
  end

  # Instance methods
  def first_purchase_of_product?
    Purchase.where(product: product, status: "completed").order(:purchase_date).first == self
  end

  def category_names
    product.category_names
  end

  def administrator
    product.administrator
  end

  private

  def set_purchase_date
    self.purchase_date = Time.current
  end

  def calculate_total_amount
    if quantity.present? && unit_price.present?
      self.total_amount = quantity * unit_price
    end
  end

  def process_purchase_completion
    return unless status == "completed"

    # Reduce stock
    product.reduce_stock!(quantity)

    # Send notification for first purchase
    if first_purchase_of_product?
      FirstPurchaseNotificationJob.perform_async(id)
    end
  end

  # Business validation methods
  def product_has_sufficient_stock
    return unless product && quantity

    if quantity > product.stock
      errors.add(:quantity, "exceeds available stock (#{product.stock} available)")
    end
  end
end
