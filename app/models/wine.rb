class Wine < ApplicationRecord
  validates :domain, presence: true
  validates :producer_id, numericality: { allow_nil: true }

  belongs_to :color
  belongs_to :region
  belongs_to :producer, optional: true
  belongs_to :provider, optional: true
  has_many :millesimes, -> { order('year') }
  accepts_nested_attributes_for :millesimes

  scope :with_bottles, -> { joins(millesimes: :bottles).distinct }
  scope :drunk, -> { joins(millesimes: [:wlogs]).where(wlogs: { mvt_type: 'out' }) }

  # Cannot define it with scope!
  def self.from_country(country)
    joins(:region).where(regions: { country_id: country.id })
  end

  # Cannot define it with scope!
  def self.from_region_and_its_descendant(region)
    joins(:region).where('regions.lft >= ? AND regions.rgt <= ?',
                         region.lft, region.rgt)
  end

  def quantity
    Wine.joins(millesimes: :bottles).where(id: id).count
  end
end
