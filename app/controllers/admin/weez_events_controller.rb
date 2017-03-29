class Admin::WeezEventsController < AdminController
  def get_items
    body_data reload: admin_weezevents_path
  end

  def index
    we_api = WeezEventApi.new

    # Let's go !
    if we_api.connected?

    # Errors
    else
      case we_api.error
      when :forbidden
        flash.now[:error] = 'Impossible de se connecter à WeezEvent (Accès refusé).'
      else
        flash.now[:error] = 'Impossible de se connecter à WeezEvent (Erreur inconnue).'
      end
    end
  end
end