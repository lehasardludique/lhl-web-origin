module ApplicationHelper
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
end
