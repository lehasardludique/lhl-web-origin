class CreateFocus < ActiveRecord::Migration[5.0]
  def change
    create_table :focus do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.belongs_to :article, index: true, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
