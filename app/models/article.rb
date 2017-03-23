class Article < ApplicationRecord
  belongs_to :user
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'
  has_one :home_carousel_link, as: :home_linkable

  enum status: { draft: 0, published: 1, restricted: 2 }

  before_validation :check_slug

  validates :title, presence: true
  validates :title_slug, uniqueness: { scope: :date_slug}, presence: true
  validate :slug_is_reserved
  validates :aside_link_1_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_2_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_3_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :event_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :info_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }

  with_options :unless => :main_gallery_present? do |u|
    u.validates :resource_id, presence: true, numericality: { only_integer: true }
  end

  attr_reader :slug, :full_url, :main_picture, :digest

  scope :visible, -> { published.where("published_at <= ?", Time.now) }
  default_scope { order(published_at: :desc) }

  def visible?
    published? and published_at <= Time.now
  end

  def media_links?
    media_link_fbk.present? or media_link_isg.present? or media_link_twt.present? or media_link_msk.present? or media_link_vid.present? or media_link_www.present?
  end
  
  def slug
    @slug ||= Rails.application.routes.url_helpers.article_path(date: self.date_slug, slug: self.title_slug) if self.date_slug.present? and self.title_slug.present?
  end

  def full_url
    @full_url ||= Rails.application.routes.url_helpers.article_url(date: self.date_slug, slug: self.title_slug, host: LHL_URL)
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
      if self.published_at_changed? and (not self.date_slug_changed? or not self.date_slug.present?)
        self.date_slug = I18n.l(self.published_at, format: :url).urlize
      end
      if self.title_changed? and (not self.title_slug_changed? or not self.title_slug.present?)
        self.title_slug = self.title.urlize.gsub(/-+/, "-").gsub(/[^a-z0-9]*$/, "")
      elsif self.title_slug_changed?
        self.title_slug = self.title_slug.split('/').map(&:urlize).join("/")
      end
    end

    def slug_is_reserved
      begin
        path = Rails.application.routes.recognize_path(self.slug, { :method => :get })
        errors.add(:slug, "Cette url est réservée.") unless (path[:controller] == 'articles' and path[:action] == 'show')
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
end