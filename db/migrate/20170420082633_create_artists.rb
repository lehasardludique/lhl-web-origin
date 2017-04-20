class CreateArtists < ActiveRecord::Migration[5.0]
  def change
    create_table :artists do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :name
      t.belongs_to :resource, index: true, foreign_key: true
      t.text :content
      t.string :media_link_fbk
      t.string :media_link_isg
      t.string :media_link_twt
      t.string :media_link_msk
      t.string :media_link_vid
      t.string :media_link_www
      t.integer :status

      t.timestamps
    end
  end
end
