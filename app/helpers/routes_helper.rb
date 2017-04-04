module RoutesHelper
  def session_path
    session[:return_to] || root_path
  end

  def current_path(*additional_params)
    # path = Rails.application.routes.recognize_path request.original_fullpath
    path = params.permit!
    path.delete(:host)
    if additional_params.present?
      additional_params.each do |p|
        path = path.merge p if p.class == Hash
      end
    end
    url_for path.merge({only_path: true})
  end

  def event_path(event, *additional_params)
    event_params = { category: event.category_slug, date: event.date_slug, title: event.title_slug }
    event_params.merge( additional_params ) if additional_params.present? and additional_params.is_a? Hash
    super(event_params) if event.is_a? Event
  end
end