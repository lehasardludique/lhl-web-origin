class FestivalEventLink < ApplicationRecord
  belongs_to :festival
  belongs_to :event
end