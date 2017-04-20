class Artist < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  enum status: { draft: 0, published: 1 }

  validates :name, presence: true
  validates :content, length: { maximum: 500 }
end