class ArtistEventLink < ApplicationRecord
  belongs_to :artist
  belongs_to :event

  default_scope { order(rank: :asc) }
end