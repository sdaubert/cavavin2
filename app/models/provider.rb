class Provider < ApplicationRecord
  belongs_to :country
  has_many :wines

  validates :name, presence: true
end
