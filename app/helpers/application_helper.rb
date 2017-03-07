module ApplicationHelper
  def session_path
    session[:return_to] || root_path
  end

  def body_classes(css = nil)
    @body_classes ||= []
    if css.present?
      @body_classes << css
    else
      css = @body_classes
      # css << "old_browser" unless browser.modern?
      css.any? ? (' class="' + css.join(' ').to_s + '"').html_safe : ""
    end
  end

  def meta_title(title = false)
    @meta_title ||= []
    if title.present?
      @meta_title << title
    else
      title = @meta_title
      # title <<  t('.subtitle') if title.count < 2
      title << "Le Hasard Ludique"
      title.join(' | ')
    end
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

  def render_header object
    if object.is_a? Page
      if object.main_gallery.present?
        render_gallery object.main_gallery, :diaporama
      elsif object.resource.present?
        render 'partials/resource', resource: object.resource
      end
    end
  end

  def render_gallery gallery, type = :gallery
    if gallery.is_a? Gallery
      if type == :diaporama
      elsif type == :gallery
      end
    end
  end
end
