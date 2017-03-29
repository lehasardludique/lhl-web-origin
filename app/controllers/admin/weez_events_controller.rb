class Admin::WeezEventsController < AdminController
  def get_items
    body_data reload: admin_weezevents_path
  end

  def index
    begin
      we_api = WeezEventApi.new
    rescue RestClient::Forbidden
      flash.now[:error] = 'Impossible de se connecter à WeezEvent'
    end
  end
end