class Country < ApplicationRecord
  has_many :regions
  has_many :producer
  has_many :provider

  validates :name, presence: true, uniqueness: true

  scope :by_name, -> { order(:name) }
end
