class ResourcesController < ApplicationController
  before_action :require_login

  def api_resources
    authorize! :list, Resource.new

    @resources_count = Resource.all.size
    page = params["draw"] || 1
    start = params["start"] || 0
    length = params["length"] || 10
    resources_attributes = Resource.new.attributes.keys

    # Scope
    scope = Resource

    # Order
    begin
      column = params["order"]["0"]["column"]
      attribute = params["columns"][column]["data"]
      order =  (defined? params["order"]["0"]["dir"]) ? params["order"]["0"]["dir"].to_sym : :asc
      if attribute.in? resources_attributes
        scope = scope.reorder(attribute.to_sym => order)
      else
        scope = scope.reorder(id: :desc)
      end
    rescue
      scope = scope.reorder(id: :desc)
    end

    # Search
    if defined? params["search"]["value"] and params["search"]["value"].present?
      q = params["search"]["value"]
      return if q.size < 3
      scope = scope.where('name ILIKE ?', "%#{q}%")
      begin
        columns = params["columns"]
        first_search = true
        columns.each do |column|
          column = column.values.first
          if column["searchable"] == "true"
            attribute = column["data"]
            scope = scope.or(where("#{attribute} ILIKE ?", "%#{q}%")) if attribute.in? resources_attributes
          end
        end
      rescue
        Rails.logger.warn "====> ResourcesController::api_resources() SEARCH QUERY ERROR for #{columns}"
      end
    end

    @filtred_resources_count = scope.size
    scope = scope.offset(start).limit(length)

    result = {
      draw: page,
      recordsTotal: @resources_count,
      recordsFiltered: @filtred_resources_count,
      data: scope.map{ |r| resource_to_json(r) }
    }
    render json: result, status: :ok
  end

  def s2_resources
    authorize! :list, Resource.new

    @resources_count = Resource.all.size

    scope = Resource
    # Scope
    if params[:scope].present? and Resource.respond_to? params[:scope].to_sym
      scope = scope.send(params[:scope].to_sym)
    end
    # Search
    q = params["q"]
    if q.present?
      scope = scope.where('name ILIKE ? OR notes ILIKE ? OR file_name ILIKE ?', "%#{q}%", "%#{q}%", "%#{q}%")
    end

    @filtred_resources_count = scope.size

    page = params["page"] || 1
    scope = scope.offset((page - 1).abs * 30).limit(30)

    result = {
      page: page,
      recordsTotal: @resources_count,
      recordsFiltered: @filtred_resources_count,
      items: scope.map{ |r| resource_to_s2_json(r) }
    }
    render json: result, status: :ok
  end

  private
    def resource_to_json resource
      {
        id: "<span class=\"badge\">#{resource.id}</span>".html_safe,  
        preview: get_preview_to_html(resource),
        name: resource.name,
        file_name: resource.file_name,
        url: resource.url,
        created_at: I18n.l(resource.created_at, format: :sortable),
        category: I18n.t("resource.categories.#{resource.category}"),
        notes: resource.notes.truncate(90, separator: ' '),
        user: resource.user.real_name,
        actions: get_actions_button(resource)
      }
    end

    def resource_to_s2_json resource
      {
        id: resource.id,  
        text: resource.name,
        url: resource.thumb_url,
      }
    end

    def get_preview_to_html resource
      if can? :read, resource
        "<a href=\"#{admin_resource_path(resource)}\"><span class=\"preview\" style=\"background-image: url('#{resource.thumb_url if defined? resource.thumb_url}')\"></span></a>".html_safe
      else
        "<span class=\"preview\" style=\"background-image: url('#{resource.thumb_url if defined? resource.thumb_url}')\"></span>".html_safe
      end
    end

    def get_actions_button resource
      buttons_list = []
      buttons_list << view_context.link_to('<i class="fa fa-eye"></i>'.html_safe, admin_resource_path(resource), title: "Détails") if can? :read, resource
      buttons_list << view_context.link_to('<i class="fa fa-pencil"></i>'.html_safe, edit_admin_resource_path(resource), title: "Éditer") if can? :edit, resource
      buttons_list << view_context.link_to('<i class="fa fa-trash"></i>'.html_safe, admin_resource_path(resource), method: :delete, data: { confirm: 'Cette action est irréversible, êtes vous sur ?' }, title: "Supprimer") if can? :delete, resource
      view_context.content_tag :div, buttons_list.join.html_safe, class: 'action'
    end
end