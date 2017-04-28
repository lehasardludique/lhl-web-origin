class Event < ApplicationRecord
  belongs_to :user
  belongs_to :focus
  belongs_to :weez_event
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'
  has_one :home_carousel_link, as: :home_linkable
  has_many :focuses, class_name: 'Focus'
  has_many :artist_event_links
  has_many :artists, -> { reorder(name: :asc) }, through: :artist_event_links
  has_many :event_partner_links
  has_many :partners, -> { reorder(name: :asc) }, through: :event_partner_links

  enum category: { family: 1, concert: 2, animations: 3, show: 4, other: 0 }
  enum place: { station: 1, hall: 4, studio: 2, dock: 3, outside: 0 }
  enum status: { draft: 0, published: 1, restricted: 2 }

  before_validation :check_slug, :check_artist_ids, :check_partner_ids

  validates :title, presence: true
  validates :title_slug, uniqueness: { scope: :date_slug}, presence: true
  validate :slug_is_reserved
  validates :aside_link_1_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_2_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :event_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :info_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :retargeting_pixel_id, allow_blank: true, numericality: { only_integer: true }

  before_save :set_display_date
  after_save :set_artists, :set_partners

  with_options :unless => :main_gallery_present? do |u|
    u.validates :resource_id, presence: true, numericality: { only_integer: true }
  end

  attr_reader :slug, :full_url, :main_picture, :digest, :category_slug
  attr_accessor :new_artist_ids, :new_partner_ids

  scope :visible, -> { published.where("published_at <= ?", Time.now) }
  scope :next, -> { visible.where("start_time >= ?", Time.now) }
  default_scope { order(published_at: :desc) }

  def self.categories_urlized
    @@categories_urlized ||= self.categories.keys.map{ |c| I18n.t( 'event.categories.' + c ).urlize }
  end

  def self.in_month number
    where("start_time >= ?", (Time.now + number.months).at_beginning_of_month).where("start_time <= ?", (Time.now + number.months).at_end_of_month)
  end

  def exchange_data weez_event
    if weez_event.is_a? WeezEvent
      self.weez_event_id = weez_event.id
      if weez_event.data['period'].present? and weez_event.data['period']['timezone'].present?
        Time.zone = weez_event.data['period']['timezone']
        self.start_time = Time.zone.parse(weez_event.data['period']['start'])
        self.end_time = Time.zone.parse(weez_event.data['period']['end'])
        self.display_date = I18n.l self.start_time, format: :display
        self.place = get_place_from weez_event.data['venue']['name'] if defined? weez_event.data['venue']['name']
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

  def booking_iframe_url
    if self.weez_event.present?
      "https://www.weezevent.com/widget_billeterie.php?id_evenement=#{self.weez_event.wid}&lg_billetterie=1&width_auto=1&color_primary=#{get_primary_color}".html_safe
    end
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

    def get_primary_color
      case self.category
      when "family"
        "6bbfa3"
      when "concert"
        "0067b1"
      when "animations"
        "ee7444"
      when "show"
        "8865c2"
      else
        "c1657d"
      end
    end

    def get_place_from place_name
      case place_name
      when /la\ salle/i then :hall
      when /atelier/i then :studio
      when /quai/i then :dock
      when /le\ hasard\ ludique/i then :station
      when /^cancelled/i then :cancelled_payment
      when nil then nil
      else :outside
      end
    end

    def check_artist_ids
      self.new_artist_ids ||= []
      self.new_artist_ids = (self.new_artist_ids - [""]).uniq
      self.artist_ids ||= []
      self.new_artist_ids = nil if self.new_artist_ids - self.artist_ids == self.artist_ids - self.new_artist_ids
    end

    def check_partner_ids
      self.new_partner_ids ||= []
      self.new_partner_ids = (self.new_partner_ids - [""]).uniq
      self.partner_ids ||= []
      self.new_partner_ids = nil if self.new_partner_ids - self.partner_ids == self.partner_ids - self.new_partner_ids
    end

    def set_display_date
      self.display_date = I18n.l(self.start_time, format: :display) if self.display_date.blank? and self.start_time.present?
    end

    def set_artists
      if self.new_artist_ids.is_a? Array
        self.artists = Artist.where(id: self.new_artist_ids)
      end
    end

    def set_partners
      if self.new_partner_ids.is_a? Array
        self.partners = Partner.where(id: self.new_partner_ids)
      end
    end
end