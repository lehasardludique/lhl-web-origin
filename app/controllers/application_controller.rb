class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper
  include RoutesHelper

  rescue_from PG::ForeignKeyViolation, with: :ooops!
  rescue_from ActiveRecord::RecordNotFound , with: :not_found!

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
      if DateTime.now.midnight < DateTime.parse('2017/04/28')
        remaing_days = (DateTime.parse('2017/04/29') - DateTime.now.midnight).to_i
        @opening = <<~OPENING
          <br />
          <br />
          Ouverture<br />
          <strong>J-#{remaing_days}</strong>
        OPENING
      else
        opening_messages = [
          OPENING_MSG_MONDAY,
          OPENING_MSG_TUESDAY,
          OPENING_MSG_WEDNESDAY,
          OPENING_MSG_THURSDAY,
          OPENING_MSG_FRIDAY,
          OPENING_MSG_SATURDAY,
          OPENING_MSG_SUNDAY
        ]
        @opening = opening_messages[Time.now.wday].html_safe
      end
    end

    def set_menu_and_footer
      @menu_links = {
        "Programmation" => events_path,
        "Billetterie" => "/billetterie",
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
