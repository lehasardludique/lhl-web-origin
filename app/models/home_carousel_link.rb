class HomeCarouselLink < ApplicationRecord
  belongs_to :home_linkable, polymorphic: true
  belongs_to :resource

  enum status: { draft: 0, published: 1 }

  attr_reader :final_title, :final_subtitle, :final_resource, :slug

  validates :home_linkable_type, presence: true
  validates :home_linkable_id, presence: true, numericality: { only_integer: true }

  default_scope { order(rank: :asc) }

  def self.types
    [ Article, Page ]
  end

  def final_title
    @final_title ||= get_final_title()
  end

  def final_subtitle
    @final_subtitle ||= get_final_subtitle()
  end

  def final_resource
    @final_resource ||= get_final_resource()
  end

  def slug
    @slug ||= get_final_slug()
  end

  private
    def get_final_title
      if self.title.present?
        self.title
      else
       (defined? self.home_linkable.title) ? self.home_linkable.title : nil
      end
    end

    def get_final_subtitle
      if self.subtitle.present?
        self.subtitle
      else
       (self.title.blank? and defined? self.home_linkable.subtitle) ? self.home_linkable.subtitle : nil
      end
    end

    def get_final_resource
      if self.resource.present?
        self.resource
      else
       (defined? self.home_linkable.main_picture) ? self.home_linkable.main_picture : nil
      end
    end

    def get_final_slug
     (defined? self.home_linkable.slug) ? self.home_linkable.slug : '#'
    end
end