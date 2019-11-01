class BottleRack < ApplicationRecord
  NO_POS = [].freeze

  has_many :wlogs
  has_many :bottles, foreign_key: 'br_id'

  validates :name, presence: true
  validates :lines, numericality: { only_integers: true }
  validates :columns, numericality: { only_integers: true }

  scope :by_name, -> { order(:name) }

  def self.millesime(mil)
    joins(:bottles).includes(:bottles)
                   .where(bottles: { millesime_id: mil.id })
                   .distinct.order(:name)
  end

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

  def size
    lines * columns
  end

  def free_location_count
    size - bottles.count
  end
end
