class EventsController < ApplicationController
  before_action :is_it_worshop?
  before_action :init_index, only: [:index]
  before_action :get_events, only: [:index, :api_events]

  def index
    @months_list = ['par mois']
    for i in 1..3
      @months_list << l(Time.now.at_beginning_of_month + i.month, format: "%B")
    end
    body_classes 'events'
    body_classes 'workshop' if @workshop
  end

  def api_events
    meta = { offset: @offset, limit: @limit, next: @meta_next, count: @events_count }
    events = @events.map{ |e| render_to_string partial: "events/wrapped_event_card", locals: { event: e }}
    response = { meta: meta, items: events }
    response['message'] = '<p class="no-event-message"><span>Aucun événement prévu pour le moment, revenez bientôt !</span></p>'.html_safe if @events_count == 0
    render json: response
  end

    def api_dt_events
    authorize! :list, Event.new

    @events_count = @workshop ? Event.workshop.all.size : Event.all.size
    page = params["draw"] || 1
    start = params["start"] || 0
    length = params["length"] || 10
    events_attributes = Event.new.attributes.keys

    # Scope
    scope =  @workshop ? Event.workshop : Event

    # Order
    begin
      column = params["order"]["0"]["column"]
      attribute = params["columns"][column]["data"]
      order =  (defined? params["order"]["0"]["dir"]) ? params["order"]["0"]["dir"].to_sym : :asc
      if attribute.in? events_attributes
        scope = scope.reorder(attribute.to_sym => order)
      else
        scope = scope.reorder(id: :desc)
      end
    rescue
      scope = scope.reorder(id: :desc)
    end

    # Search
    if defined? params["search"]["value"] and params["search"]["value"].present?
      q = params["search"]["value"]
      return if q.size < 3
      #scope = scope.where('title ILIKE ? OR display_date ILIKE ?', "%#{q}%", "%#{q}%")
      scope = case q
      when /(^\d{4}\/\d{2}$)/
        start_time = parse_zoned_time q
        end_time = start_time.at_end_of_month
        scope.where('(start_time >= ? AND start_time < ?) OR (end_time >= ? AND end_time < ?)', start_time, end_time, start_time, end_time)
      when /^\d{4}\/\d{2}\/\d{2}$/
        start_time = parse_zoned_time q
        end_time = start_time.at_end_of_day
        scope.where('(start_time >= ? AND start_time < ?) OR (end_time >= ? AND end_time < ?)', start_time, end_time, start_time, end_time)
      else
        scope.where('title ILIKE ? OR display_date ILIKE ?', "%#{q}%", "%#{q}%")
      end
      # begin
      #   columns = params["columns"]
      #   first_search = true
      #   columns.each do |column|
      #     column = column.values.first
      #     if column["searchable"] == "true"
      #       attribute = column["data"]
      #       scope = scope.or(where("#{attribute} ILIKE ?", "%#{q}%")) if attribute.in? events_attributes
      #     end
      #   end
      # rescue
      #   Rails.logger.warn "====> EventsController::api_dt_events() SEARCH QUERY ERROR for #{columns}"
      # end
    end

    @filtred_events_count = scope.size
    scope = scope.offset(start).limit(length)

    result = {
      draw: page,
      recordsTotal: @events_count,
      recordsFiltered: @filtred_events_count,
      data: scope.map{ |e| event_to_dt_json(e) }
    }
    render json: result, status: :ok
  end

  def show
    if @workshop
      @event = Event.workshop.find_by! title_slug: params[:slug]
    else
      @event = Event.find_by! date_slug: params[:date], title_slug: params[:slug]
    end
    if
    (not @event.visible? and not logged_in?) or
    (@event.draft? and (not logged_in? or not @event.user == current_user)) or
    (@event.restricted? and not logged_in?)
      not_found!
    end
    redirect_to event_path(@event) unless params[:category] == @event.category_slug
    meta_title @event.title
    set_meta_og @event
    @retargeting_pixel_id = @event.retargeting_pixel_id
    body_classes 'page'
    body_classes @event.category
  end

  private
    def event_to_dt_json event
      {
        id: "<span class=\"badge\">#{event.id}</span>".html_safe,  
        title: event.title,
        event_alert: event.ongoing? ? "-" : I18n.t("event.event_alerts.#{event.event_alert}"),
        preview: get_preview_to_html(event),
        published_at: I18n.l(event.published_at, format: :sortable),
        start_time: I18n.l(event.start_time, format: :sortable),
        end_time: I18n.l(event.end_time, format: :sortable),
        display_date: event.display_date,
        url: event.path,
        updated_at: I18n.l(event.updated_at, format: :sortable),
        user: event.user.real_name,
        status: I18n.t("event.statuses.#{event.status}"),
        weez_event: get_weez_event_button(event),
        actions: get_actions_button(event)
      }
    end

    def is_it_worshop?
      @workshop = !!params[:workshop]
    end

    def init_index
      @offset = 0
    end

    def get_events
      @focus = Focus.current
      @categories = @workshop ? Event.workshop_categories.keys.map(&:to_sym) : Event.pure_categories.keys.map(&:to_sym)
      @offset ||= (params[:offset].present? and params[:offset].to_i > 0) ? params[:offset].to_i : 0
      @limit = (params[:limit].present? and params[:limit].to_i > 0) ? params[:limit].to_i : 12
      
      scope = @workshop ? Event.workshop.next : Event.next

      if params[:focus].present?
        @focus = Focus.published.find_by(id: params[:focus].to_i) if params[:focus].to_s.to_i > 0
        if @focus.present?
          @active_focus = true
          scope = @workshop ? Event.where(focus_id: @focus.id).workshop.visible : Event.where(focus_id: @focus.id).visible
        end
      end

      # categories
      unless params[:categories].blank?
        @active_categories = params[:categories].map(&:to_sym) & @categories
        scope = @workshop ? scope.where(workshop_category: @active_categories) : scope.where(pure_category: @active_categories)
      else
        @active_categories = @categories
      end

      # date
      if params[:month] and params[:month].to_i > 0
        @month = params[:month].to_i
        scope = scope.in_month(@month)
      else
        @month = 0
      end

      @events_count = scope.count
      @meta_next = ((@offset+@limit+1) >= @events_count) ? nil : "offset=#{@offset+@limit}&limit=#{@limit}"

      # order
      if @workshop
        scope = scope.reorder(workshop_rank: :asc, title: :asc)
      else
        scope = scope.reorder(end_time: :asc)
      end

      @events = scope.offset(@offset).limit(@limit)
    end

    def parse_zoned_time q
      Time.zone = "Paris"
      Time.zone.parse q
    end

    def get_preview_to_html event
      if event.main_picture.present?
        url = defined?(event.main_picture.thumb_url) ? event.main_picture.thumb_url : nil
        ("<span class=\"preview\" style=\"background-image: url('" + url.to_s + "')\"></span>").html_safe
      end
    end

    def get_weez_event_button event
      if event.weez_event.present?
        buttons_list = []
        buttons_list << view_context.link_to('<i class="fa fa-ticket"></i>'.html_safe, event.weez_event.mini_site, title: "Mini-Site WeezEvent")
        buttons_list << view_context.link_to('<i class="fa fa-sliders"></i>'.html_safe, "https://www.weezevent.com/bo/tableau_bord_accueil.php?id_evenement=#{event.weez_event.wid}", title: "Back Office WeezEvent")
        view_context.content_tag :div, buttons_list.join.html_safe, class: 'action'
      end
    end

    def get_actions_button event
      buttons_list = []
      buttons_list << view_context.link_to('<i class="fa fa-eye"></i>'.html_safe, admin_event_path(event), title: "Détails") if can? :read, event
      buttons_list << view_context.link_to('<i class="fa fa-pencil"></i>'.html_safe, edit_admin_event_path(event), title: "Éditer") if can? :edit, event
      buttons_list << view_context.link_to('<i class="fa fa-trash"></i>'.html_safe, admin_event_path(event), method: :delete, data: { confirm: 'Cette action est irréversible, êtes vous sur ?' }, title: "Supprimer") if can? :delete, event
      view_context.content_tag :div, buttons_list.join.html_safe, class: 'action'
    end
end