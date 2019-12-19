class Dish < ApplicationRecord
  TYPES = %w[starter meat fish speciality cheese dessert].freeze

  validates :name,  presence: true, uniqueness: true
  validates :dish_type, presence: true, inclusion: { in: TYPES }

  has_many :dras, dependent: :destroy
  has_many :regions, through: :dras

  scope :by_name, -> { order(:name) }

  def region_color?(region, color)
    dras.where(region: region.id, color: color.id).count == 1
  end
end
