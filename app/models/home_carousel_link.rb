class HomeCarouselLink < ApplicationRecord
  belongs_to :home_linkable, polymorphic: true

  enum status: { draft: 0, published: 1 }

  validates :home_linkable_type, presence: true
  validates :home_linkable_id, presence: true, numericality: { only_integer: true }

  default_scope { order(rank: :asc) }

  def self.types
    [ Article, Page ]
  end
end