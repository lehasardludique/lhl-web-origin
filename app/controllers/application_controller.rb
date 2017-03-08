class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper

  rescue_from PG::ForeignKeyViolation, with: :ooops!

  after_action :store_location

  def not_found!
    @no_menu = true
    body_classes 'bubble'
    meta_title t('errors.not_found.meta')
    @title = t 'errors.not_found.title'
    @text = t 'errors.not_found.text'
    render :error, status: :not_found and return
  end

  def ooops!
    flash[:error] = "La resource à effacer est liée à un autre objet. Merci de supprimer cette liaison avant de réessayer."
    redirect_back(fallback_location: session_path)
  end

  private
    def store_location
      session[:return_to] = request.fullpath unless request.fullpath =~ /^\/api\//
    end
end
