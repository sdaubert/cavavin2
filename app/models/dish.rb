class Dish < ApplicationRecord
  TYPES = ['Starter', 'Meal', 'Fish/Seafood', 'Speciality', 'Cheese',
           'Dessert'].sort.freeze

  validates :name,  presence: true, uniqueness: true
  validates :dish_type, presence: true, inclusion: { in: TYPES }

  has_many :dras, dependent: :destroy
  has_many :regions, through: :dras

  def region_color?(region, color)
    dras.where(region: region.id, color: color.id).count == 1
  end
end
