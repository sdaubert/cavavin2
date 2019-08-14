class Color < ApplicationRecord
  has_many :wines
  has_many :dras

  validates :name, presence: true, uniqueness: true
end
