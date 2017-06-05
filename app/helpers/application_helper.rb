module ApplicationHelper
  def body_classes(css = nil)
    @body_classes ||= []
    if css.present?
      @body_classes << css unless css.in? @body_classes
    else
      css = @body_classes
      # css << "old_browser" unless browser.modern?
      css.any? ? (' class="' + css.join(' ').to_s + '"').html_safe : ""
    end
  end

  def body_data(data = nil)
    @body_data ||= []
    if data.class.in? [Hash, Array]
      data.each do |d|
        html_attribute = "data-#{d.first}=\"#{d.last}\""
        @body_data << html_attribute unless html_attribute.in? @body_data
      end
    elsif data.nil?
      data = @body_data
      if data.any?
        " #{data.join(' ')}".html_safe
      else
        ""
      end
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

  def render_meta_og
    render 'layouts/meta_og' unless @og.blank?
  end

  def set_meta_og(object)
    @og ||= {}
    if object.class.in? [ Page, Article, Festival ]
      @og[:url] = object.full_url
      @og[:title] = object.title
      @og[:description] = object.digest
      @og[:image] = object.main_picture.present? ? object.main_picture.url : ActionController::Base.helpers.image_url('logo_le-hasard-ludique_600.png', host: LHL_URL)
    end
  end

  def render_header object
    if object.class.in? [ Page, Festival, Article, Event ]
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
        render 'partials/carousel', gallery: gallery
      elsif type == :gallery
        body_classes 'gallery'
        render 'partials/gallery', gallery: gallery
      end
    end
  end

  def link_from(link_data, css = [])
    if link_data =~ INTERNAL_LINK_FORMAT
      link_data = link_data.split /\ >\ /
      link_title = link_data.first
      link_object = link_data.last
      css = css.split " " unless css.is_a? Array

      # Link to Object
      if /^(Article:\d|Fichier:\d|Page:\d)/.match link_object
        link_object = link_object.split ':'
        # dynamic_class = Object.const_get link_object.first
        case link_object.first
        when 'Article'
          object = Article.find_by id: link_object.last.to_i
          object_path = object.path
        when 'Fichier'
          object = Resource.find_by id: link_object.last.to_i
          object_path = object.url
          object_target = :_blank
        when 'Page'
          object = Page.find_by id: link_object.last.to_i
          object_path = object.path
        end
        link_to link_title, object_path, target: object_target, class: (css.any? ? css.join(' ') : nil) if object
      
      # Link to internal path
      elsif /^\//.match link_object
        link_to link_title, link_object, class: (css.any? ? css.join(' ') : nil)
      
      # Link to external URI
      elsif /^http/.match link_object
        link_to link_title, link_object, target: '_blank', class: (css.any? ? css.join(' ') : nil)

      # Mail to
      elsif /^mailto:/.match link_object
        if link_title  =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
          link_name = link_title.gsub(/\./, ' . ')
          link_name = link_name.gsub(/@/, ' <i class="fa fa-at" aria-hidden="true"></i> ')
        else
          link_name = link_title
          css << 'ntt'
        end
        link_destination = link_object.gsub(/^mailto:/, '')
        link_destination = link_destination.split('@')
        link_to link_name.html_safe, '#', data: {mail: link_destination[0], domain: link_destination[1] }, class: (css.any? ? css.join(' ') : nil)
      end
    end
  end

  def active_link_to title, href, css = nil
    css = css.to_s.split " "
    css << 'active' if request.fullpath =~ /^#{Regexp.quote(href)}/
    link_to title, href, class: css.join(" "), target: /^http/.match(href) ? :_blank : nil
  end
end
