class Category < ApplicationRecord
  # PaperTrail auditing
  has_paper_trail

  # Associations
  belongs_to :administrator
  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false },
            length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 500 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :with_products, -> { joins(:products).distinct }

  # Callbacks
  before_validation :normalize_name

  # Instance methods
  def products_count
    products.count
  end

  def active_products
    products.where(active: true)
  end

  private

  def normalize_name
    self.name = name.strip.titleize if name.present?
  end
end
