class Client < ApplicationRecord
  # Associations
  has_many :purchases, dependent: :restrict_with_error
  has_many :products, through: :purchases

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, presence: true, length: { minimum: 8, maximum: 20 }
  validates :address, length: { maximum: 500 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :with_purchases, -> { joins(:purchases).distinct }

  # Callbacks
  before_validation :normalize_email
  before_validation :normalize_phone

  # Instance methods
  def total_purchases
    purchases.count
  end

  def total_spent
    purchases.sum(:total_amount)
  end

  def favorite_products(limit = 5)
    products.joins(:purchases)
            .group('products.id')
            .order('COUNT(purchases.id) DESC')
            .limit(limit)
  end

  def first_purchase
    purchases.order(:purchase_date).first
  end

  def last_purchase
    purchases.order(:purchase_date).last
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def normalize_phone
    self.phone = phone.gsub(/\D/, '') if phone.present?
  end
end
