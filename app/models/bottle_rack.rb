class BottleRack < ApplicationRecord

  NO_POS = []

  has_many :wlogs
  has_many :bottles

  validates :name, presence: true
  validates :lines, numericality: { only_integers: true }
  validates :columns, numericality: { only_integers: true }

  def self.pos_to_ary(pos)
    if pos.nil?
      NO_POS
    else
      pos.split(',').map(&:to_i)
    end
  end

  def self.ary_to_pos(ary)
    ary.join(',')
  end
end
