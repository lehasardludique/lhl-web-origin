class CreateEventPartnerLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :event_partner_links do |t|
      t.belongs_to :event, index: true, foreign_key: true
      t.belongs_to :partner, index: true, foreign_key: true
      t.integer :rank, default: 0
    end
  end
end
