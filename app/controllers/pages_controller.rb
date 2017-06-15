class PagesController < ApplicationController
  def home
    @home_carousels_links = HomeCarouselLink.published
    @events = Event.next.limit(6).reorder(end_time: :asc)
    @retargeting_pixel_id = ENV['KLOX_HOME_PIXEL'] if ENV['KLOX_HOME_PIXEL']
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

  def partners
    @partners_page = Rails.cache.fetch(:partners_page, expires_in: 24.hours) do
      PartnersPage.new
    end
    @section_1_partners = Partner.where(id: @partners_page.section_1_ids)
    @section_2_partners = Partner.where(id: @partners_page.section_2_ids)
    @section_3_partners = Partner.where(id: @partners_page.section_3_ids)
    not_found! if not(@section_1_partners.any? or @section_2_partners.any? or @section_3_partners.any?)
    meta_title "Les partenaires"
    body_classes 'page partners'
  end
end