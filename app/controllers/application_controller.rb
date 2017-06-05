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

  before_action :set_modal, :set_opening_time, :get_menu_and_footer
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
      # INFO MODAL
      Time.zone = 'Paris'
      now = Time.zone.now
      im = InfoMessage.published.modal.where('start_at <= ?', now).where('end_at >= ?', now).first
      cookies.delete :info if "quelles-sont-les-news".in? params.keys
      if im.present?
        if not cookies[:info] == "IM-#{im.id}"
          cookies[:info] = { value: "IM-#{im.id}", expires: im.end_at }
          @info_modal = im
        end
      end

      # NEWSLETTER MODAL
      newsletter_modal_forced = "la-newsletter".in? params.keys
      if newsletter_modal_forced or not cookies[:newsletter]
        session[:pages_count] ||= 0
        session[:pages_count] += 1
        if (newsletter_modal_forced or session[:pages_count] > 3) and not @info_modal
          @newletter_modal = true
          cookies[:newsletter] = true unless newsletter_modal_forced
        end
      end

      # RESET COOKIES
      if "reset-cookies".in? params.keys
        cookies.delete :info
        cookies.delete :newsletter
        session[:pages_count] = nil
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

    def get_menu_and_footer
      @menu_links = Rails.cache.fetch(:menu_links, expires_in: 24.hours) do
        set_menu()
      end
      @footer_1_links = Rails.cache.fetch(:footer_1_links, expires_in: 24.hours) do
        set_footer_left()
      end
      @footer_2_links = Rails.cache.fetch(:footer_2_links, expires_in: 24.hours) do
        set_footer_right()
      end
    end

    def authorize
      unless logged_in?
        store_location
        redirect_to login_path and return
      end
    end

    def set_menu
      links_menu = MenuLink.published.menu
      if links_menu.any?
        links = {}
        links_menu.each do |link|
          links[link.title] = link.path
        end
        links
      else
        {
          "Programmation" => events_path,
          "Billetterie" => "/billetterie",
          "Activités" => workshops_path,
          "Infos pratiques" => "/infos-pratiques"
        }
      end
    end

    def set_footer_left
      links_menu = MenuLink.published.footer_left
      if links_menu.any?
        links = {}
        links_menu.each do |link|
          links[link.title] = link.path
        end
        links
      else
        {
          "Mentions légales" => "/mentions-legales"
        }
      end
    end

    def set_footer_right
      links_menu = MenuLink.published.footer_right
      if links_menu.any?
        links = {}
        links_menu.each do |link|
          links[link.title] = link.path
        end
        links
      else
        {
          "Privatisation" => "/privatiser-le-hasard-ludique"
        }
      end
    end
end
