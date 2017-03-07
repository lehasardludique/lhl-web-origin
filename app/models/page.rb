class Page < ApplicationRecord
  belongs_to :user
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'

  enum status: { draft: 0, published: 1, restricted: 2 }
end