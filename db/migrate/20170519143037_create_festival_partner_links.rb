class CreateFestivalPartnerLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :festival_partner_links do |t|
      t.belongs_to :festival, index: true, foreign_key: true
      t.belongs_to :partner, index: true, foreign_key: true
      t.integer :rank, default: 0
    end
  end
end
