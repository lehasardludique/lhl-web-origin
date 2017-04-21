class Partner < ApplicationRecord
  belongs_to :user
  belongs_to :resource
  enum category: { unspecified_category: 0 }

  validates :name, presence: true
  validates :resource_id, presence: true, numericality: { only_integer: true }
end