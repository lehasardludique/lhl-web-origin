class Focus < ApplicationRecord
  belongs_to :article

  enum status: { draft: 0, published: 1 }

  validates :start, presence: true
  validates :end, presence: true
  validates :title, presence: true
  validates_each :end do |record, attr, value|
    record.errors.add(attr, "Le focus doit commencer avant de se terminer&nbsp;!".html_safe) if record.start > record.end
  end

  default_scope { order(end: :desc) }
end