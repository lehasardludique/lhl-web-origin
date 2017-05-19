class Gallery < ApplicationRecord
  belongs_to :user
  has_many :image_ships
  has_many :resources, -> { reorder('image_ships.rank ASC') }, through: :image_ships

  enum category: { event: 0, article: 1, global: 2 }

  before_destroy :delete_links

  attr_accessor :form, :new_resource_id, :new_resource_rank, :resource_new_rank

  private
    def delete_links
      self.image_ships.delete_all
    end
end