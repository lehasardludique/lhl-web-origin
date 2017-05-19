class AdminController < ApplicationController
  before_action :authorize

  private
    def authorize
      unless logged_in?
        store_location
        redirect_to login_path and return
      end
    end
end