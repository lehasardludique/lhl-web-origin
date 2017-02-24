class CreateImageShips < ActiveRecord::Migration[5.0]
  def change
    create_table :image_ships do |t|
        t.belongs_to :gallery, index: true, foreign_key: true
        t.belongs_to :resource, index: true, foreign_key: true
        t.integer :rank, default: 1

        t.timestamps
    end
  end
end
