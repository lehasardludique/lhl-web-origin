class ImageShip < ApplicationRecord
  belongs_to :gallery
  belongs_to :resource

  validates :gallery_id, presence: true, numericality: { only_integer: true }
  validates :resource_id, presence: true, numericality: { only_integer: true }
end