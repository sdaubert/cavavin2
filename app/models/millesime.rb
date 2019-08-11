class Millesime < ApplicationRecord
  DRINK_DIFF = "millesimes.garde + millesimes.year - cast(strftime('%Y', date('now')) AS integer)"

  belongs_to :wine
  has_many :wlogs
  has_many :bottles

  validates :wine, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id }
  validates :garde, presence: true, numericality: { only_integer: true }

  scope :from_region, ->(region) { joins(wine: :region).where(wines: { region: region.id}) }
  scope :with_bottles, -> { joins(:bottles).distinct }
  scope :without_bottles, -> { left_outer_joins(:bottles).distinct
                                .select('millesimes.*, COUNT(bottles.id) AS bottles_count')
                                .group('millesimes.id')
                                .having('bottles_count == 0') }
  scope :drink_before, ->(years) { where("#{DRINK_DIFF} < ?", years) }
  scope :drink_after, ->(years) { where("#{DRINK_DIFF} >= ?", years) }

  def quantity
    Millesime.joins(:bottles).where(id: id).count
  end
end
