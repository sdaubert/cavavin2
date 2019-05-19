class Wine < ApplicationRecord
  validates :domain, presence: true
  validates :producer_id, numericality: { allow_nil: true }

  belongs_to :color
  belongs_to :region
  belongs_to :producer, optional: true
  belongs_to :provider, optional: true
  has_many :millesimes
end
