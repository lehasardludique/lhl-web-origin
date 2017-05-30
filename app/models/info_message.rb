class InfoMessage < ApplicationRecord
  enum status: { draft: 0, published: 1, restricted: 2 }

  validates :modal_content, presence: true, if: :modal?
  validates :opening_content, presence: true, if: :opening?
  validates :title, :start_at, :end_at, presence: true
  validates_each :end_at do |record, attr, value|
    record.errors.add(attr, "La date de fin de message doit être postérieure à la date de débutnbsp;!".html_safe) if record.start_at > record.end_at
  end

  scope :modal, -> { where(modal: true) }
  scope :opening, -> { where(opening: true) }
  default_scope { order(end_at: :desc) }

  def modal?
    self.modal || false
  end

  def opening?
    self.opening || false
  end
end