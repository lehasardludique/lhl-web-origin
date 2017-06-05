class AdminController < ApplicationController
  before_action :authorize
  skip_before_action :set_modal, :set_opening_time, :get_menu_and_footer

  private
    def authorize
      unless logged_in?
        store_location
        redirect_to login_path and return
      end
    end
end