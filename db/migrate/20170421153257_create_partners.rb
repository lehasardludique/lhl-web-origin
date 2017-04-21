class CreatePartners < ActiveRecord::Migration[5.0]
  def change
    create_table :partners do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.string :link
      t.belongs_to :resource, index: true, foreign_key: true
      t.text :notes
      t.integer :category, default: 0
      
      t.timestamps
    end
  end
end
