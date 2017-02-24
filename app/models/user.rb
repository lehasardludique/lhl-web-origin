class User < ApplicationRecord
  authenticates_with_sorcery!

  enum role: { editor: 1, admin: 5 }
  enum status: [ :disabled, :active ]
  
  validates :email, uniqueness: true, presence: true

  with_options :if => :password_change? do |u|
    u.validates :password, length: { minimum: 6 }
    u.validates :password, confirmation: true
    u.validates :password_confirmation, presence: true
  end

  attr_accessor :remember, :form

  def real_name(option = nil)
    rn = []
    rn << first_name if first_name.present?
    rn << last_name if last_name.present?
    rn << email if rn.blank?
    rn << "(#{id})" if option == :with_id or rn.count == 1
    rn.join " "
  end

  private
    def password_change?
      form == 'password'
    end
end
