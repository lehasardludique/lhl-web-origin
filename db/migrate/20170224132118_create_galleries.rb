class CreateGalleries < ActiveRecord::Migration[5.0]
  def change
    create_table :galleries do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.integer :category, default: 0

      t.timestamps
    end
  end
end
