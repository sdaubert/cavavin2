class Region < ApplicationRecord
  acts_as_nested_set scope: :country

  validates_presence_of :name, :country_id

  belongs_to :country
  has_many :wines
  has_many :dras
  has_many :dishes, through: :dras
  has_and_belongs_to_many :colors

  scope :by_country, ->(country_id) { where('regions.country_id = ?', country_id) }
  scope :by_name, -> { order(:name) }

  def direct_descendants
    Region.children_of(self.id)
  end

  def all_descendants
    Region.left_of(self.rgt).right_of(self.lft)
  end

  def color?(color)
    colors.where(id: color.id).count.positive?
  end

  def dishes_by_color(color)
    dras.by_regions.of_color(color).map(&:dish)
  end
end
