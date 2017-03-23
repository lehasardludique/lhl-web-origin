class HomeCarouselLink < ApplicationRecord
  belongs_to :home_linkable, polymorphic: true

  enum status: { draft: 0, published: 1 }
end