class Artist < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  has_many :artist_event_links
  has_many :events, -> { reorder(start_time: :desc) }, through: :artist_event_links
  enum status: { draft: 0, published: 1 }

  validates :name, presence: true
  validates :content, length: { maximum: 650 }

  def media_links?
    media_link_fbk.present? or media_link_isg.present? or media_link_twt.present? or media_link_msk.present? or media_link_vid.present? or media_link_www.present?
  end
end