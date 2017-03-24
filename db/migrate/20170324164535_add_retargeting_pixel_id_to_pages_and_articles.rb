class AddRetargetingPixelIdToPagesAndArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :retargeting_pixel_id, :bigint
    add_column :articles, :retargeting_pixel_id, :bigint
  end
end
