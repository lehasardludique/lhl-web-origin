module AdminHelper
  def new_admin_focus_path
    new_admin_focu_path
  end

  def edit_admin_focus_path(focus)
    edit_admin_focu_path(focus)
  end

  def admin_focus_path(options = nil)
    if not options.nil? and (options.class.in? [ Focus, Integer ] or (options.is_a? Hash and options[:id].present?))
      admin_focu_path(options)
    else
      super
    end
  end
end