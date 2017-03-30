class AddFieldsToWeezEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :weez_events, :date, :datetime
    add_column :weez_events, :mini_site, :string
  end
end
