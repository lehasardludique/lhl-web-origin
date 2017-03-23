class ImageShip < ApplicationRecord
  belongs_to :gallery
  belongs_to :resource

  attr_accessor :form

  validates :gallery_id, presence: true, numericality: { only_integer: true }
  validates :resource_id, presence: true, numericality: { only_integer: true }

  default_scope { order(rank: :asc) }

  after_save :check_rank_consistency

  private
    def check_rank_consistency
      if self.rank_changed? and not self.form == :callback
        order_direction = self.rank > self.rank_was ? :asc : :desc
        ImageShip.where(gallery_id: self.gallery_id).reorder(rank: :asc, updated_at: order_direction).each_with_index do |is, i|
          is.form = :callback
          is.update(rank: i + 1) unless is.rank == i + 1
        end
      end
    end
end