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
  end

  def api_events
    meta = { offset: @offset, limit: @limit, next: @meta_next, count: @events_count }
    events = @events.map{ |e| render_to_string partial: "events/wrapped_event_card", locals: { event: e }}
    response = { meta: meta, items: events }
    response['message'] = '<p class="no-event-message"><span>Aucun événement prévu pour le moment, revenez bientôt !</span></p>'.html_safe if @events_count == 0
    render json: response
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
    def is_it_worshop?
      @workshop = !!params[:workshop]
    end

    def init_index
      @offset = 0
    end

    def get_events
      @focus = Focus.current
      @categories = Event.categories.keys.map(&:to_sym)
      @offset ||= (params[:offset].present? and params[:offset].to_i > 0) ? params[:offset].to_i : 0
      @limit = (params[:limit].present? and params[:limit].to_i > 0) ? params[:limit].to_i : 12
      
      scope = Event.next

      if params[:focus].present?
        @focus = Focus.published.find_by(id: params[:focus].to_i) if params[:focus].to_s.to_i > 0
        if @focus.present?
          @active_focus = true
          scope = @focus.events.visible
        end
      end

      # categories
      unless params[:categories].blank?
        @active_categories = (params[:categories] & Event.categories.keys).map(&:to_sym)
        scope = scope.where(category: @active_categories)
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

      @events = scope.reorder(start_time: :asc).offset(@offset).limit(@limit)
    end
end