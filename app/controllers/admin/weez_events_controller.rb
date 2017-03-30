class Admin::WeezEventsController < AdminController
  def get_items
    body_data reload: admin_weezevents_path(update: :normal)
  end

  def index
    if params[:update].present?
      we_api = WeezEventApi.new

      # Let's go !
      if we_api.connected?
        we_api.update_events!(params[:update] == :forced) if params[:update].in? [:forced, 'normal']
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
    @weez_events = WeezEvent.all
  end

  def delete
    @weez_event = WeezEvent.find(params[:id])
    @weez_event.destroy
    flash.notice = "WeezEvent supprimé avec succès."
    flash[:info] = "Ce WeezEvent sera sera réimporté au prochain chargement si il est toujours présent chez WeezEvent."
    redirect_to admin_weezevents_path
  end
end