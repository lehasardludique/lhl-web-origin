class Gallery < ApplicationRecord
  belongs_to :user
  has_many :image_ships
  has_many :resources, through: :image_ships

  enum category: { event: 0, article: 1, global: 2 }
end