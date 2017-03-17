class AddIndexOnPageSlug < ActiveRecord::Migration[5.0]
  def change
    add_index :pages, :slug
  end
end
