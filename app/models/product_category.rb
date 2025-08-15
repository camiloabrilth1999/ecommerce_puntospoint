class ProductCategory < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :category

  # Validations
  validates :product_id, uniqueness: { scope: :category_id }

  # Scopes
  scope :active_products, -> { joins(:product).where(products: { active: true }) }
  scope :active_categories, -> { joins(:category).where(categories: { active: true }) }
end
