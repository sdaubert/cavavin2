class Bottle < ApplicationRecord
  belongs_to :millesime
  belongs_to :bottle_rack, foreign_key: 'br_id', optional: true

  validates :br_id, numericality: { only_integers: true }, allow_nil: true
  validates :pos, presence: true, if: :bottle_rack?

  def bottle_rack?
    !br_id.nil?
  end
end
