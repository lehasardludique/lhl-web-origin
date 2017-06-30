class Resource < ApplicationRecord
  include ExtendedErrors

  belongs_to :user
  has_many :articles
  has_many :artists
  has_many :events
  has_many :image_ships
  has_many :galleries, through: :image_ships
  has_many :home_carousel_links
  has_many :partners
  has_many :pages
  has_many :menu_links, as: :object

  mount_uploader :handle, ResourceUploader

  enum category: { gallery: 0, global: 1 }

  before_destroy :check_dependencies
  after_save :menu_links_cache_management, :store_file_name

  validates :handle, :presence => true
  validate :handle_size_validation, on: :create

  attr_reader :url, :thumb_url, :title
  attr_accessor :file_name_stored

  default_scope { order(updated_at: :desc) }

  def title
    @title || get_title
  end

  def url
    @url || get_url
  end

  def thumb_url
    @thumb_url || get_version_url(:thumb)
  end

  def file_name_stored
    @file_name_stored ||= false
  end

  private
    def handle_size_validation
      errors[:handle] << "doit peser moins de 2 Mo" if handle.size > 2.megabytes
    end

    def get_title
      self.name || "#{self.id} (sans nom)"
    end

    def get_url
      self.handle.url
    end

    def get_version_url(version)
      if self.handle.send(version).present?
        self.handle.send(version).url
      elsif self.handle.content_type.start_with? 'image'
        self.handle.url
      else
        # file icon
        ActionController::Base.helpers.image_url 'file_icon.svg'
      end
    end

    def menu_links_cache_management
      if self.menu_links.any?
        MenuLink.delete_cache
      end
    end

    def check_dependencies
      if self.articles.any? or self.artists.any? or self.events.any? or self.image_ships.any? or self.galleries.any? or self.home_carousel_links.any? or self.partners.any? or self.pages.any?
        model_list = []
        model_list << "article(s) (#{self.articles.pluck(:id).join(', ')})" if self.articles.any?
        model_list << "artiste(s) (#{self.artists.pluck(:id).join(', ')})" if self.artists.any?
        model_list << "évènement(s) (#{self.events.pluck(:id).join(', ')})" if self.events.any?
        model_list << "galerie(s) (#{self.galleries.pluck(:id).join(', ')})" if self.image_ships.any? or self.galleries.any?
        model_list << "slide(s) de home (#{self.home_carousel_links.pluck(:id).join(', ')})" if self.home_carousel_links.any?
        model_list << "partenaire(s) (#{self.partners.pluck(:id).join(', ')})" if self.partners.any?
        model_list << "page(s) (#{self.pages.pluck(:id).join(', ')})" if self.pages.any?
        raise DependencyDestructionError.new "Cette resource est encore liée à certains objets : #{model_list.join(', ')}<br />Merci de supprimer ces objets ou leur liaison avec l'image en premier."
        if self.menu_links.any?
          raise DependencyDestructionError.new "Cette resource est l'objet d'un ou plusieurs liens du menu ou du footer (#{self.menu_links.pluck(:id).join(', ')})<br />Merci de le(s) supprimer en premier."
        end
      end
    end

    def store_file_name
      if not self.file_name_stored
        self.update(file_name: self.handle_identifier) if not self.file_name == self.handle_identifier
        self.file_name_stored = true
      end
    end
end