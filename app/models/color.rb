class Color < ApplicationRecord
  has_many :wines
  has_many :dras
  has_and_belongs_to_many :regions

  validates :name, presence: true, uniqueness: true
  validates :color, presence: true

  scope :with_wines, -> { joins(:wines).distinct }
  scope :with_bottles, -> { joins(wines: [millesimes: [:bottles]]).distinct }
  scope :by_name, -> { order(:name) }
end
