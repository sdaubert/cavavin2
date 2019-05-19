class Wlog < ApplicationRecord
  MVT_TYPES = %w[in out move].freeze

  belongs_to :millesime

  validates :mvt_type, inclusion: { in: MVT_TYPES }
  validates :quantity, numericality: { only_integers: true }
  validates :price, numericality: true, if: :mvt_types_is_in?

  private

  def mvt_types_is_in?
    mvt_type == 'in'
  end
end
