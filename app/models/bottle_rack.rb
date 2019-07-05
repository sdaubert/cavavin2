class BottleRack < ApplicationRecord
  validates :name, presence: true
  validates :lines, numericality: { only_integers: true }
  validates :columns, numericality: { only_integers: true }
end
