class PagesController < ApplicationController
  def home
    @home_carousels_links = HomeCarouselLink.published
    @retargeting_pixel_id = 8147450
    body_classes 'home'
  end

  def wip
    @no_menu = true
    body_classes 'wip'
  end

  def redirect
    redirect_to "http://lafabrique.lehasardludique.paris#{request.fullpath}", status: :moved_permanently
  end

  def show
    @page = Page.find_by! slug: params[:slug]
    not_found! if @page.draft? and (not logged_in? or not @page.user == current_user)
    not_found! if @page.restricted? and not logged_in?
    meta_title @page.title
    set_meta_og @page
    @retargeting_pixel_id = @page.retargeting_pixel_id
    body_classes 'page'
  end
end