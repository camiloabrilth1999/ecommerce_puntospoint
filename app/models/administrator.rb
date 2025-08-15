class Administrator < ApplicationRecord
  has_secure_password

  # PaperTrail auditing
  has_paper_trail

  # Associations
  has_many :products, dependent: :restrict_with_error
  has_many :categories, dependent: :restrict_with_error

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin manager] }
  validates :password, length: { minimum: 8 }, if: :password_required?

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_role, ->(role) { where(role: role) }

  # Callbacks
  before_validation :normalize_email

  # Class methods
  def self.admins
    where(role: "admin")
  end

  def self.managers
    where(role: "manager")
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def password_required?
    new_record? || password.present?
  end
end
