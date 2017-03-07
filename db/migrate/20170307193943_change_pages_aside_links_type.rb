class ChangePagesAsideLinksType < ActiveRecord::Migration[5.0]
  def change
    change_column :pages, :aside_link_1_data, :string
    change_column :pages, :aside_link_2_data, :string
    change_column :pages, :event_link_data, :string
    change_column :pages, :info_link_data, :string
    add_column :pages, :aside_link_3_data, :string
  end
end
