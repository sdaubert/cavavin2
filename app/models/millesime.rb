class Millesime < ApplicationRecord
  belongs_to :wine
  has_many :wlogs
  has_many :bottles

  validates :wine, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id }
  validates :garde, presence: true, numericality: { only_integer: true }

  scope :with_bottles, -> { joins(:bottles).distinct }
  scope :drink_before, ->(years) { select("millesimes.*, millesimes.garde + millesimes.year - cast(strftime('%Y', date('now')) as integer) AS diff").
                                   where('diff < ?', years)}

  def quantity
    Millesime.joins(:bottles).where(id: id).count
  end
end
