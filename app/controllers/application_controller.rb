class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper

  after_action :store_location

  private
    def store_location
      session[:return_to] = request.fullpath unless request.fullpath =~ /^\/api\//
    end
end
