class Color < ApplicationRecord
  has_many :wines

  validates :name, presence: true, uniqueness: true
end
