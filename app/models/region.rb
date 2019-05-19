class Region < ApplicationRecord
  acts_as_nested_set scope: :country

  validates_presence_of :name, :country_id

  belongs_to :country

  scope :by_country, lambda { |country_id| where('regions.country_id = ?', country_id) }
end
