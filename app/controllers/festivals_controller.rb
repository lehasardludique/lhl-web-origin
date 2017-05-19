class FestivalsController < ApplicationController
  def show
    @festival = Festival.find_by! slug: params[:slug]
    not_found! if @festival.draft? and (not logged_in? or not @festival.user == current_user)
    not_found! if @festival.restricted? and not logged_in?
    meta_title @festival.title
    set_meta_og @festival
    @retargeting_pixel_id = @festival.retargeting_pixel_id
    body_classes 'page festival'
  end
end