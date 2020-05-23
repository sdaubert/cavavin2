# Dish-Region Association
class Dra < ApplicationRecord
  belongs_to :dish
  belongs_to :region
  belongs_to :color

  scope :of_color, ->(color) { where(color: color.id) }
  scope :by_regions, -> { joins(:region).order('regions.name') }
  scope :by_dishes, -> { joins(:dish).order('dishes.name') }
end
