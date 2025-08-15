class Product < ApplicationRecord
  # PaperTrail auditing
  has_paper_trail

  # Associations
  belongs_to :administrator
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :purchases, dependent: :restrict_with_error
  has_many :clients, through: :purchases
  has_many_attached :images

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: { case_sensitive: false }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :images, presence: true, unless: :skip_image_validation?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock > 0") }
  scope :by_category, ->(category_id) { joins(:categories).where(categories: { id: category_id }) }
  scope :by_administrator, ->(admin_id) { where(administrator_id: admin_id) }
  scope :most_purchased, -> { joins(:purchases).group("products.id").order("COUNT(purchases.id) DESC") }
  scope :highest_revenue, -> { joins(:purchases).group("products.id").order("SUM(purchases.total_amount) DESC") }

  # Callbacks
  before_validation :generate_sku, if: -> { sku.blank? }
  before_validation :normalize_name

  # Instance methods
  def total_purchased
    purchases.sum(:quantity)
  end

  def total_revenue
    purchases.sum(:total_amount)
  end

  def first_purchase
    purchases.order(:purchase_date).first
  end

  def category_names
    categories.pluck(:name).join(", ")
  end

  def in_stock?
    stock > 0
  end

  def out_of_stock?
    stock == 0
  end

  def reduce_stock!(quantity)
    return false if stock < quantity

    update!(stock: stock - quantity)
    true
  end

  private

  def skip_image_validation?
    Rails.env.development? || Rails.env.test?
  end

  def generate_sku
    self.sku = "PRD-#{SecureRandom.hex(4).upcase}"
  end

  def normalize_name
    self.name = name.strip.titleize if name.present?
  end
end
