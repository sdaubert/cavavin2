class Millesime < ApplicationRecord
  belongs_to :wine
  has_many :wlogs

  validates :wine, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id }
  validates :garde, presence: true, numericality: { only_integer: true }

  def quantity
    ins = wlogs.where(mvt_type: 'in').sum(:quantity)
    outs = wlogs.where(mvt_type: 'out').sum(:quantity)
    ins - outs
  end
end
