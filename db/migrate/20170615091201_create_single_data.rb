class CreateSingleData < ActiveRecord::Migration[5.0]
  def change
    create_table :single_data do |t|
      t.string :k, index: true
      t.jsonb :v, default: []

      t.timestamps
    end
  end
end
