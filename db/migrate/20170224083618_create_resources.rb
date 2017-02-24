class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :handle
      t.string :name
      t.text :notes
      t.integer :category, default: 0

      t.timestamps
    end
  end
end
