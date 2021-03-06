class Producer < ApplicationRecord
  belongs_to :country
  has_many :wines

  validates :name, presence: true
  validates :web, url: { scheme: %w[http https] }, allow_blank: true
  validates :email, format: /@/, allow_blank: true

  scope :by_name, -> { order(:name) }
end
