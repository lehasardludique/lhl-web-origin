class CreateWeezEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :weez_events do |t|
        t.bigint :wid, index: true
        t.string :title
        t.string :image
        t.jsonb :data

        t.timestamps
    end
  end
end
