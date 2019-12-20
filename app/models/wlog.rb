class Wlog < ApplicationRecord
  MVT_TYPES = %w[in out move].freeze

  belongs_to :millesime
  belongs_to :bottle_rack, foreign_key: 'br_id', optional: true

  validates :mvt_type, inclusion: { in: MVT_TYPES }
  validates :quantity, numericality: { only_integers: true }
  validates :price, numericality: true, if: :mvt_type_is_in?

  validates :br_id, numericality: { only_integers: true }, allow_nil: true
  validates :pos, presence: true, if: :bottle_rack?
  validates :move_to_br_id, numericality: { only_integers: true }, allow_nil: true
  validates :move_to_pos, presence: true, if: :move_to_bottle_rack?

  def mvt_type_is_in?
    mvt_type == 'in'
  end

  def mvt_type_is_move?
    mvt_type == 'move'
  end

  def bottle_rack?
    !br_id.nil?
  end

  def move_to_bottle_rack?
    !move_to_br_id.nil?
  end

  def has_bottle_rack?
    bottle_rack? || move_to_bottle_rack?
  end

  private

  def move_to_bottle_rack?
    !move_to_br_id.nil?
  end
end
