class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :main_gallery, index: true
      t.belongs_to :resource, index: true, foreign_key: true
      t.string :title
      t.string :subtitle
      t.text :content
      t.belongs_to :final_gallery, index: true
      t.text :exergue
      t.jsonb :aside_link_1_data
      t.jsonb :aside_link_2_data
      t.boolean :social_block
      t.jsonb :event_link_data
      t.jsonb :info_link_data
      t.string :slug
      t.integer :status

      t.timestamps
    end

    add_foreign_key :pages, :galleries, column: :main_gallery_id
    add_foreign_key :pages, :galleries, column: :final_gallery_id
  end
end
