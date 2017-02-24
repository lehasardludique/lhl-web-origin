class ImageShip < ApplicationRecord
  belongs_to :gallery
  belongs_to :resource
end