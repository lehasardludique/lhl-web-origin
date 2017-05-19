class ChangeFestivalsAttributes < ActiveRecord::Migration[5.0]
  def change
    add_column :festivals, :topic, :string
    remove_column :festivals, :aside_link_3_data, :string
  end
end
