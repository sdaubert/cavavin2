class Millesime < ApplicationRecord
  DRINK_DIFF = '(millesimes.garde + millesimes.year - ' \
               "cast(strftime('%Y', date('now')) AS integer))".freeze

  belongs_to :wine, required: false
  has_many :wlogs
  accepts_nested_attributes_for :wlogs
  has_many :bottles

  validates :year, presence: true,
                   numericality: { only_integer: true },
                   uniqueness: { scope: :wine_id },
                   allow_nil: true
  validates :garde, presence: { if: :garde_required? },
                    numericality: { only_integer: true, if: :garde_required? }

  # Cannot define it with scope!
  def self.from_region(region)
    joins(wine: :region).where(wines: { region: region.id })
  end

  scope :from_producer, ->(prod) { joins(:wine).where(wines: { producer: prod.id }) }
  scope :from_provider, ->(prov) { joins(:wine).where(wines: { provider: prov.id }) }
  scope :with_bottles, -> { joins(:bottles).distinct }

  # Cannot define it with scope!
  def self.without_bottles
    left_outer_joins(:bottles).distinct
                              .unscope(:select)
                              .group('millesimes.id')
                              .having('COUNT(bottles.id) == 0')
  end

  scope :drink_before, ->(years) { where.not(year: nil).where("#{DRINK_DIFF} < ?", years) }
  scope :drink_after, ->(years) { where.not(year: nil).where("#{DRINK_DIFF} >= ?", years) }

  scope :of_color, ->(color) { joins(wine: [:color]).where(wines: { color: color.id }) }
  scope :by_year, -> { order(:year) }

  def quantity
    Millesime.joins(:bottles).where(id: id).count
  end

  # Give years before wine is at its culmination
  def years_to_drink_wine
    year + garde - Time.now.year
  end

  private

  def garde_required?
    !year.nil?
  end
end
