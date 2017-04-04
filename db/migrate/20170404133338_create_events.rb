class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :focus, index: true, foreign_key: true
      t.integer :category
      t.belongs_to :weez_event, index: true, foreign_key: true
      t.string :display_date
      t.datetime :start_time
      t.datetime :end_time
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
      t.boolean :social_block
      t.string :event_link_data
      t.string :info_link_data
      t.datetime :published_at
      t.string :title_slug, index: true
      t.string :date_slug, index: true
      t.bigint :retargeting_pixel_id
      t.integer :status

      t.timestamps
    end

    add_foreign_key :events, :galleries, column: :main_gallery_id
    add_foreign_key :events, :galleries, column: :final_gallery_id
  end
end
