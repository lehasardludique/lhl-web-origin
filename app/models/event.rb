class Event < ApplicationRecord
  belongs_to :user
  belongs_to :focus
  belongs_to :weez_event
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'
  has_one :home_carousel_link, as: :home_linkable
  has_many :focuses, class_name: 'Focus'

  enum category: { family: 1, concert: 2, animations: 3, show: 4, other: 0 }
  enum status: { draft: 0, published: 1, restricted: 2 }

  before_validation :check_slug

  validates :title, presence: true
  validates :title_slug, uniqueness: { scope: :date_slug}, presence: true
  validate :slug_is_reserved
  validates :aside_link_1_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_2_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :event_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :info_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :retargeting_pixel_id, allow_blank: true, numericality: { only_integer: true }

  with_options :unless => :main_gallery_present? do |u|
    u.validates :resource_id, presence: true, numericality: { only_integer: true }
  end

  attr_reader :slug, :full_url, :main_picture, :digest, :category_slug

  scope :visible, -> { published.where("published_at <= ?", Time.now) }
  default_scope { order(published_at: :desc) }

  def self.categories_urlized
    @@categories_urlized ||= self.categories.keys.map{ |c| I18n.t( 'event.categories.' + c ).urlize }
  end

  def exchange_data weez_event
    if weez_event.is_a? WeezEvent
      self.weez_event_id = weez_event.id
      if weez_event.data['period'].present? and weez_event.data['period']['timezone'].present?
        zone = ActiveSupport::TimeZone[weez_event.data['period']['timezone']]
        weez_event.data['period']
        self.start_time = "#{weez_event.data['period']['start']} #{zone.formatted_offset(false)}"
        self.end_time = "#{weez_event.data['period']['end']} #{zone.formatted_offset(false)}"
        self.display_date = I18n.l self.start_time, format: :display
      end
      self.title = weez_event.data['title'] if weez_event.data['title'].present?
      # self.subtitle =
      self.content = weez_event.data['description'] if weez_event.data['description'].present?
      self.exergue = set_exergue_from weez_event
    end
  end

  def visible?
    published? and published_at <= Time.now
  end

  def media_links?
    media_link_fbk.present? or media_link_isg.present? or media_link_twt.present? or media_link_msk.present? or media_link_vid.present? or media_link_www.present?
  end
  
  def slug
    @slug ||= Rails.application.routes.url_helpers.event_path(category: self.category_slug, date: self.date_slug, slug: self.title_slug) if self.date_slug.present? and self.title_slug.present?
  end

  def category_slug
    @category_slug ||= (I18n.t("event.categories.#{self.category}")).urlize
  end

  def full_url
    @full_url ||= Rails.application.routes.url_helpers.event_url(category: self.category_slug, date: self.date_slug, slug: self.title_slug, host: LHL_URL)
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
        errors.add(:slug, "Cette url est réservée.") unless (path[:controller] == 'events' and path[:action] == 'show')
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

    def set_exergue_from weez_event
      if weez_event.is_a? WeezEvent and weez_event.data.present?
        exergue_data = { start: self.start_time, place: nil, full_price: nil, reduced_price: nil }
        exergue_data[:place] = weez_event.data['venue']['name'] if defined? weez_event.data['venue']['name']
        exergue_data[:full_price] = weez_event.data['price']['max'].gsub(/\./, ',') if defined? weez_event.data['price']['max']
        exergue_data[:reduced_price] = weez_event.data['price']['min'].gsub(/\./, ',') if defined? weez_event.data['price']['min']
        ApplicationController.new.render_to_string "events/exergue", layout: false, locals: { exergue_data: exergue_data }
      end
    end
end