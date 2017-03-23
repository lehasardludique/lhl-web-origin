class HomeCarouselLink < ApplicationRecord
  belongs_to :home_linkable, polymorphic: true

  enum status: { draft: 0, published: 1 }

  default_scope { order(rank: :asc) }
end