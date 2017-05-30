class CreateInfoMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :info_messages do |t|
      t.boolean :modal
      t.boolean :opening
      t.datetime :start_at
      t.datetime :end_at
      t.string :title
      t.text :modal_content
      t.text :opening_content
      t.integer :status

      t.timestamps
    end
  end
end
