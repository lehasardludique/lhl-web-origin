class Festival < ApplicationRecord
  include ExtendedErrors
  
  belongs_to :user
  belongs_to :weez_event
  belongs_to :main_gallery, class_name: 'Gallery'
  belongs_to :resource
  belongs_to :final_gallery, class_name: 'Gallery'
  has_one :home_carousel_link, as: :home_linkable
  has_many :festival_event_links
  has_many :events, through: :festival_event_links

  enum status: { draft: 0, published: 1, restricted: 2 }

  attr_reader :path, :full_url, :main_picture, :digest, :form_path
  attr_accessor :new_event_ids, :new_workshop_ids

  before_validation :check_slug, :check_event_ids
  before_destroy :check_dependencies

  validates :title, presence: true
  validates :slug, uniqueness: true, presence: true
  validate :slug_is_reserved
  validates :aside_link_1_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :aside_link_2_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :event_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :info_link_data, allow_blank: true, format: { with: INTERNAL_LINK_FORMAT }
  validates :retargeting_pixel_id, allow_nil: true, numericality: { only_integer: true }

  with_options :unless => :main_gallery_present? do |u|
    u.validates :resource_id, presence: true, numericality: { only_integer: true }
  end

  after_save :set_events

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

  def new_event_ids
    @new_event_ids ||= self.events.pluck(:id)
  end

  def new_workshop_ids
    @new_workshop_ids ||= self.events.workshop.pluck(:id)
  end

  def exchange_data weez_event
    if weez_event.is_a? WeezEvent
      self.weez_event_id = weez_event.id
      self.title = weez_event.data['title'] if weez_event.data['title'].present?
      # self.subtitle =
      self.content = weez_event.data['description'] if weez_event.data['description'].present?
      self.exergue = set_exergue_from weez_event
    end
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
      "https://www.weezevent.com/widget_billeterie.php?id_evenement=#{self.weez_event.wid}&lg_billetterie=1&width_auto=1&color_primary=fff482".html_safe
    end
  end

  private
    def set_exergue_from weez_event
      if weez_event.is_a? WeezEvent and weez_event.data.present?
        exergue_data = { start: self.start_time, place: nil, full_price: nil, reduced_price: nil }
        exergue_data[:place] = weez_event.data['venue']['name'] if defined? weez_event.data['venue']['name']
        exergue_data[:full_price] = weez_event.data['price']['max'].gsub(/\./, ',') if defined? weez_event.data['price']['max']
        exergue_data[:reduced_price] = weez_event.data['price']['min'].gsub(/\./, ',') if defined? weez_event.data['price']['min']
        ApplicationController.new.render_to_string "events/exergue", layout: false, locals: { exergue_data: exergue_data }
      end
    end

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

    def check_event_ids
      # Event
      self.new_event_ids ||= []
      self.new_event_ids = (self.new_event_ids - [""]).uniq
      event_ids = self.events.pluck(:id)
      self.new_event_ids = nil if self.new_event_ids - event_ids == event_ids - self.new_event_ids
      # Workshop
      self.new_workshop_ids ||= []
      self.new_workshop_ids = (self.new_workshop_ids - [""]).uniq
      workshop_ids = self.events.workshop.pluck(:id)
      self.new_workshop_ids = nil if self.new_workshop_ids - workshop_ids == workshop_ids - self.new_workshop_ids
    end

    def set_events
      if self.new_event_ids.is_a? Array and self.new_workshop_ids.is_a? Array
        self.events = Event.all_kinds.where(id: self.new_event_ids + self.new_workshop_ids)
      end
    end
end