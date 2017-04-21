class EventPartnerLink < ApplicationRecord
  belongs_to :event
  belongs_to :partner

  default_scope { order(rank: :asc) }
end