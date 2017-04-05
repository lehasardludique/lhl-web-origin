class WeezEvent < ApplicationRecord
  has_many :events
  
  default_scope { order(date: :desc) }
end