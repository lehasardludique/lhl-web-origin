class ImageShip < ApplicationRecord
  belongs_to :gallery
  belongs_to :resource

  validates :gallery_id, presence: true, numericality: { only_integer: true }
  validates :resource_id, presence: true, numericality: { only_integer: true }

  default_scope { order(rank: :asc) }

  after_save :check_rank_consistency

  private
    def check_rank_consistency
      if self.rank_changed? or self.id_changed?
        switched_image_ship = ImageShip.where.not(id: self.id).find_by(gallery_id: self.gallery_id, rank: self.rank)
        if switched_image_ship
          switched_image_ship_new_rank = (self.id_changed?) ? ImageShip.where(gallery_id: self.gallery_id).count : self.rank_was
          Rails.logger.info "----> NEW RANK #{switched_image_ship_new_rank}"
          switched_image_ship.update( rank: switched_image_ship_new_rank )
        end
      end
    end
end