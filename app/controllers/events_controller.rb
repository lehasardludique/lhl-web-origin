class EventsController < ApplicationController
  before_action :get_current_focus, only: [:index]
  before_action :get_events, only: [:index, :api_events]

  def index
    body_classes 'events'
  end

  def api_events
    meta = { offset: @offset, limit: @limit, next: @meta_next, count: @events_count }
    events = @events.map{ |e| render_to_string partial: "events/wrapped_event_card", locals: { event: e }}
    render json: { meta: meta, items: events }
  end

  def show
    @event = Event.find_by! date_slug: params[:date], title_slug: params[:slug]
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
    def get_current_focus
      @focus = Focus.current
      @offset = 0
    end

    def get_events
      @categories = Event.categories.keys.map(&:to_sym)
      @offset ||= (params[:offset].present? and params[:offset].to_i > 0) ? params[:offset].to_i : 0
      @limit = (params[:limit].present? and params[:limit].to_i > 0) ? params[:limit].to_i : 3
      
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
        @active_categories = (params[:categories].split & Event.categories.keys).map(&:to_sym)
        scope = scope.where(category: @active_categories)
      else
        @active_categories = @categories
      end

      # date
      if params[:mois] and params[:mois].to_i > 0
        scope = scope.in_months(params[:mois].to_i)
      end

      @events_count = scope.count
      @meta_next = ((@offset+@limit+1) >= @events_count) ? nil : "offset=#{@offset+@limit}&limit=#{@limit}"

      @events = scope.reorder(start_time: :asc).offset(@offset).limit(@limit)
    end
end