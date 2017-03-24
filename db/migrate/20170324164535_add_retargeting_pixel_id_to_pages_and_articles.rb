class AddRetargetingPixelIdToPagesAndArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :retargeting_pixel_id, :integer
    add_column :articles, :retargeting_pixel_id, :integer
  end
end
