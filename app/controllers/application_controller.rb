class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ExtendedErrors
  include ApplicationHelper
  include RoutesHelper

  rescue_from PG::ForeignKeyViolation, with: :ooops!
  rescue_from ActiveRecord::RecordNotFound , with: :not_found!
  rescue_from ExtendedErrors::DependencyDestructionError do |exception|
    flash[:error] = exception.to_s
    redirect_back fallback_location: admin_root_path
  end

  before_action :set_opening_time, :set_menu_and_footer
  after_action :store_location

  def not_found!
    @no_menu = true
    @no_footer = true
    body_classes 'bubble'
    meta_title t('errors.not_found.meta')
    @title = t 'errors.not_found.title'
    @text = t'errors.not_found.text'
    render 'layouts/error', status: :not_found and return
  end

  def ooops!
    flash[:error] = "La resource à effacer est liée à un autre objet. Merci de supprimer cette liaison avant de réessayer."
    redirect_back(fallback_location: session_path)
  end

  private
    def store_location
      session[:return_to] = request.fullpath unless request.fullpath =~ /^\/api\//
    end

    def set_opening_time
      opening_messages = [
        OPENING_MSG_SUNDAY,
        OPENING_MSG_MONDAY,
        OPENING_MSG_TUESDAY,
        OPENING_MSG_WEDNESDAY,
        OPENING_MSG_THURSDAY,
        OPENING_MSG_FRIDAY,
        OPENING_MSG_SATURDAY
      ]
      Time.zone = 'Paris'
      @opening = opening_messages[Time.zone.now.wday].html_safe
    end

    def set_menu_and_footer
      @menu_links = {
        "Programmation" => events_path,
        "Billetterie" => "/billetterie",
        "Activités" => workshops_path,
        "Infos pratiques" => "/infos-pratiques"
      }
      @footer_1_links = {
        "Mentions légales" => "/mentions-legales"
      }
      @footer_2_links = {
        "Privatisation" => "/privatiser-le-hasard-ludique"
      }
    end
end
