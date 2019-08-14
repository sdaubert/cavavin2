class Dish < ApplicationRecord
  TYPES = ['Starter', 'Meal', 'Fish/Seafood', 'Speciality', 'Cheese',
           'Dessert'].sort.freeze

  validates :name,  presence: true, uniqueness: true
  validates :dish_type, presence: true, inclusion: { in: TYPES }

  has_many :dras, dependent: :destroy
  has_many :regions, through: :dras
end
