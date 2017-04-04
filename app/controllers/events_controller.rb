class EventsController < ApplicationController
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
    body_classes @event.category_slug
  end
end