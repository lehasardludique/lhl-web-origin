class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper

  after_action :store_location

  def not_found!
    @no_menu = true
    body_classes 'bubble'
    meta_title t('errors.not_found.meta')
    @title = t 'errors.not_found.title'
    @text = t 'errors.not_found.text'
    render :error, status: :not_found and return
  end

  private
    def store_location
      session[:return_to] = request.fullpath unless request.fullpath =~ /^\/api\//
    end
end
