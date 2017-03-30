class WeezEvent < ApplicationRecord
  default_scope { order(date: :desc) }
end