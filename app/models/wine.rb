class Wine < ApplicationRecord
  validates :domain, presence: true
  validates :producer_id, numericality: { allow_nil: true }

  belongs_to :color
  belongs_to :region
  belongs_to :producer, optional: true
  belongs_to :provider, optional: true
  has_many :millesimes
  accepts_nested_attributes_for :millesimes

  scope :with_bottles, -> { joins(millesimes: :bottles).distinct }
  scope :from_country, ->(c) { joins(:region).where(regions: { country_id: c.id }) }
  scope :from_region_and_its_descendant, ->(r) { joins(:region).where('regions.lft >= ? AND regions.rgt <= ?', r.lft, r.rgt) }

  def quantity
    Wine.joins(millesimes: :bottles).where(id: id).count
  end
end
