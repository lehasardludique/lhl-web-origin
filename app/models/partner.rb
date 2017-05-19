class Partner < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  has_many :event_partner_links
  has_many :events, -> { reorder(start_time: :desc) }, through: :event_partner_links
  has_many :festival_partner_links
  has_many :festivals, through: :festival_partner_links
  enum category: { unspecified_category: 0 }

  default_scope { order(name: :asc) }

  validates :name, presence: true
  validates :resource_id, presence: true, numericality: { only_integer: true }
end