class FestivalPartnerLink < ApplicationRecord
  belongs_to :festival
  belongs_to :partner

  default_scope { order(rank: :asc) }
end