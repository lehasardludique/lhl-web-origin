class CreateHomeCarouselLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :home_carousel_links do |t|
      t.integer :home_linkable_id
      t.string  :home_linkable_type
      t.integer :rank
      t.string  :title
      t.string  :subtitle
      t.belongs_to :resource, index: true, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end

    add_index :home_carousel_links, [:home_linkable_type, :home_linkable_id], name: 'index_home_carousel_links'
  end
end
