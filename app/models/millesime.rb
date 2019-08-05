class Millesime < ApplicationRecord
  belongs_to :wine
  has_many :wlogs
  has_many :bottles

  validates :wine, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id }
  validates :garde, presence: true, numericality: { only_integer: true }

  def quantity
    Millesime.joins(:bottles).where(id: id).count
  end
end
