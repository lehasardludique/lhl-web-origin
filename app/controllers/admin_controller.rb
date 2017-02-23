class AdminController < ApplicationController
  before_action :authorize

  private
    def authorize
      unless logged_in?
        store_location
        redirect_to login_path and return
      end
      # unless current_user.admin?
      #   flash.alert = "L'interface d'administration est réservée aux administrateurs."
      #   redirect_to root_path
      # end
    end
end