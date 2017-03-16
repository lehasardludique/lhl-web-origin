class PagesController < ApplicationController
  def home
    body_classes 'wip'
    @no_menu = true
  end

  def redirect
    redirect_to "//lafabrique.lehasardludique.paris/#{params[:slug]}", status: :moved_permanently
  end

  def show
    @page = Page.find_by! slug: params[:slug]
    not_found! if @page.draft? and (not logged_in? or not @page.user == current_user)
    not_found! if @page.restricted? and not logged_in?
    meta_title @page.title
    set_meta_og @page
    body_classes 'page'
  end
end