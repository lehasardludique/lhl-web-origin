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
    event_params = { category: event.category_slug, date: event.date_slug, slug: event.title_slug }
    event_params.merge( additional_params ) if additional_params.present? and additional_params.is_a? Hash
    super(event_params) if event.is_a? Event
  end

  def admin_event_path(event)
    if event.workshop?
      admin_workshop_path(event)
    else
      super
    end
  end

  def admin_path object
    case object
    when Article then admin_article_path object
    when Page then admin_page_path object
    when Event then admin_event_path object
    end
  end

  def admin_events_path
    if @workshop
      admin_workshops_path
    else
      super
    end
  end

  def edit_admin_event_path(event)
    if event.workshop?
      edit_admin_workshop_path event
    else
      super
    end
  end

  def new_admin_event_path *args
    if @workshop
      new_admin_workshop_path args
    else
      super
    end
  end
end