class AddFieldsToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :workshop, :boolean, default: false
    add_column :events, :workshop_category, :integer
    add_column :events, :workshop_rank, :integer, default: 10
    rename_column :events, :category, :pure_category
  end
end
