class Admin::WeezEventsController < AdminController
  def get_items
    body_data reload: admin_weezevents_path
  end

  def index
    we_api = WeezEventApi.new

    # Let's go !
    we_api.update_events! if we_api.connected?
    @weez_events = WeezEvent.all

    # Errors
    if not we_api.connected?
      case we_api.error
      when :forbidden
        flash.now[:error] = 'Impossible de se connecter à WeezEvent (Accès refusé).'
      else
        flash.now[:error] = 'Impossible de se connecter à WeezEvent (Erreur inconnue).'
      end
    end
  end
end