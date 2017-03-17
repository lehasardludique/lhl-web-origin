class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :topic
      t.belongs_to :main_gallery, index: true
      t.belongs_to :resource, index: true, foreign_key: true
      t.string :title
      t.string :subtitle
      t.text :content
      t.belongs_to :final_gallery, index: true
      t.text :exergue
      t.string :aside_link_1_data
      t.string :aside_link_2_data
      t.string :aside_link_3_data
      t.boolean :social_block
      t.string :event_link_data
      t.string :info_link_data
      t.string :media_link_fbk
      t.string :media_link_isg
      t.string :media_link_twt
      t.string :media_link_msk
      t.string :media_link_vid
      t.string :media_link_www
      t.datetime :published_at
      t.string :title_slug, index: true
      t.string :date_slug, index: true
      t.integer :status

      t.timestamps
    end

    add_foreign_key :articles, :galleries, column: :main_gallery_id
    add_foreign_key :articles, :galleries, column: :final_gallery_id
  end
end
