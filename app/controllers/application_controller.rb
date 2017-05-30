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
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Vous n'êtes pas autorisé à accéder ou modifier cette resource."
    redirect_back fallback_location: admin_root_path
  end

  before_action :set_modal, :set_opening_time, :set_menu_and_footer
  before_action :authorize if Rails.env.staging?
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

    def set_modal
      Time.zone = 'Paris'
      now = Time.zone.now
      im = InfoMessage.published.modal.where('start_at <= ?', now).where('end_at >= ?', now).first
      cookies.delete :info if "quelles-sont-les-news".in? params.keys
      if im.present?
        Rails.logger.info "----> COOKIE: #{cookies[:info]} | MESSAGE: IM-#{im.id}"
        if not cookies[:info] == "IM-#{im.id}"
          cookies[:info] = { value: "IM-#{im.id}", expires: im.end_at }
          @info_modal = im
        end
      end
    end

    def set_opening_time
      Time.zone = 'Paris'
      now = Time.zone.now
      im = InfoMessage.published.opening.where('start_at <= ?', now).where('end_at >= ?', now).first
      if im.present? and im.opening_content.present?
        @opening = im.opening_content.html_safe
      else
        opening_messages = [
          OPENING_MSG_SUNDAY,
          OPENING_MSG_MONDAY,
          OPENING_MSG_TUESDAY,
          OPENING_MSG_WEDNESDAY,
          OPENING_MSG_THURSDAY,
          OPENING_MSG_FRIDAY,
          OPENING_MSG_SATURDAY
        ]
        @opening = opening_messages[now.wday].html_safe
      end
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

    def authorize
      unless logged_in?
        store_location
        redirect_to login_path and return
      end
    end
end
