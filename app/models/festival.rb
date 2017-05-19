class Festival < ApplicationRecord
  include ExtendedErrors
  
  belongs_to :user
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'
  has_one :home_carousel_link, as: :home_linkable

  enum status: { draft: 0, published: 1, restricted: 2 }

  before_validation :check_slug
  before_destroy :check_dependencies

  validates :title, presence: true
  validates :slug, uniqueness: true, presence: true
  validate :slug_is_reserved
  validates :aside_link_1_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_2_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_3_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :event_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :info_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :retargeting_pixel_id, numericality: { only_integer: true }

  with_options :unless => :main_gallery_present? do |u|
    u.validates :resource_id, presence: true, numericality: { only_integer: true }
  end

  attr_reader :path, :full_url, :main_picture, :digest, :form_path

  scope :visible, -> { published }

  def path
    @path ||= Rails.application.routes.url_helpers.festival_path(slug: self.slug) if self.slug.present?
  end

  def form_path
    @form_path ||= self.new_record? ? Rails.application.routes.url_helpers.admin_festivals_path : Rails.application.routes.url_helpers.admin_festival_path(self)
  end

  def full_url
    @full_url ||= Rails.application.routes.url_helpers.festival_url(slug: self.slug, host: LHL_URL) if self.slug.present?
  end

  def main_picture
    @main_picture ||= get_main_picture
  end

  def digest
    @digest ||= get_digest
  end

  def facebook_url
    data = {
      u: self.full_url,
      title: self.title
    }
    "https://www.facebook.com/sharer/sharer.php?#{URI.encode_www_form(data)}"
  end

  def twitter_url
    data = {
      text: self.title,
      url: self.full_url,
      hashtags: 'LeHasardLudique',
      via: 'Lehasardludique'
    }
    "https://twitter.com/intent/tweet?#{URI.encode_www_form(data)}"
  end

  private
    def get_main_picture
      if self.main_gallery.present?
        self.main_gallery.resources.first
      elsif self.resource.present?
        self.resource
      end
    end

    def check_slug
      if self.title_changed? and (not self.slug_changed? or not self.slug.present?)
        self.slug = self.title.urlize.gsub(/-+/, "-").gsub(/[^a-z0-9]*$/, "")
      elsif self.slug_changed?
        self.slug = self.slug.split('/').map(&:urlize).join("/")
      end
    end

    def slug_is_reserved
      begin
        path = Rails.application.routes.recognize_path(self.path, { :method => :get })
        errors.add(:slug, "Cette url est réservée.") unless (path[:controller] == 'festivals' and path[:action] == 'show')
      rescue
        return
      end
    end

    def get_digest
      ActionController::Base.helpers.truncate(ActionController::Base.helpers.strip_tags(self.content), length: 250, separator: ' ', omission: ' [...]')
    end

    def main_gallery_present?
      self.main_gallery.present?
    end

    def check_dependencies
      if self.home_carousel_link.present?
        raise DependencyDestructionError.new "Ce festival est liée à un slide de Home (#{self.home_carousel_link.id})<br />Merci de le supprimer en premier."
      end
    end
end