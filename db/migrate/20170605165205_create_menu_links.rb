class CreateMenuLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :menu_links do |t|
      t.string :title
      t.string :link_content
      t.integer :rank, default: 10
      t.references :object, polymorphic: true, index: true
      t.boolean :target_blank, default: false
      t.string :path
      t.integer :place
      t.integer :status

      t.timestamps
    end
  end
end
