class Artist < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  has_many :artist_event_links
  has_many :events, -> { reorder(start_time: :desc) }, through: :artist_event_links
  enum status: { draft: 0, published: 1 }

  validates :name, presence: true
  validates :content, length: { maximum: 500 }
end