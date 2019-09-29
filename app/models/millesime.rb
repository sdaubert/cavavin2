class Millesime < ApplicationRecord
  DRINK_DIFF = "millesimes.garde + millesimes.year - cast(strftime('%Y', date('now')) AS integer)"

  belongs_to :wine
  has_many :wlogs
  accepts_nested_attributes_for :wlogs
  has_many :bottles

  validates :wine, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id }
  validates :garde, presence: true, numericality: { only_integer: true }

  scope :from_region, ->(region) { joins(wine: :region).where(wines: { region: region.id}) }
  scope :with_bottles, -> { joins(:bottles).distinct }
  scope :without_bottles, lambda { left_outer_joins(:bottles).distinct
                                  .unscope(:select)
                                  .group('millesimes.id')
                                  .having('COUNT(bottles.id) == 0') }
  scope :drink_before, ->(years) { where("#{DRINK_DIFF} < ?", years) }
  scope :drink_after, ->(years) { where("#{DRINK_DIFF} >= ?", years) }

  def quantity
    Millesime.joins(:bottles).where(id: id).count
  end

  # Give years before wine is at its culmination
  def years_to_drink_wine
    year + garde - Time.now.year
  end
end
