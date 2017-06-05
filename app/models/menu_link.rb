class MenuLink < ApplicationRecord
  belongs_to :object, polymorphic: true

  enum place: { menu: 0, footer_left: 1, footer_right: 2 }
  enum status: { draft: 0, published: 1 }

  validates :title, presence: true
  validates :link_content, presence: true

  before_save :set_object_and_path

  default_scope { order(rank: :asc) }

  private
    def set_object_and_path
      if /^(Article:\d|Fichier:\d|Page:\d|Event:\d|Workshop:\d)/.match self.link_content
        pre_object = self.link_content.split ':'
        case pre_object.first
        when 'Article'
          self.object = Article.find_by id: pre_object.last.to_i
        when 'Fichier'
          self.object = Resource.find_by id: pre_object.last.to_i
          self.target_blank = true
        when 'Page'
          self.object = Page.find_by id: pre_object.last.to_i
        when 'Event'
          self.object = Event.find_by id: pre_object.last.to_i
        when 'Workshop'
          self.object = Event.workshop.find_by id: pre_object.last.to_i
        end
        self.path = self.object.respond_to?(:path) ? self.object.path : '#'
      elsif /^http/.match self.link_content
        self.path = self.link_content
        self.target_blank = true
      else
        self.path = ('/' + self.link_content).gsub(/^(\/\/)/, '/')
      end
    end
end