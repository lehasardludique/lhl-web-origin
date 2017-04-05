require 'base64'
require 'rack'

module CustomSassFunctions
  def svg_to_data(template, color = '#fff482')
    begin
      template = 'svg/' + template.to_s.gsub(/["'"]/, '')
      svg = ApplicationController.new.render_to_string template, locals: { color: color }
      base64 = Base64.encode64(svg).gsub(/\s+/, "")
      Sass::Script::String.new("url(data:image/svg+xml;base64,#{Rack::Utils.escape(base64)})")
    rescue
      Sass::Script::String.new("none")
    end
  end
end

::SassC::Script::Functions.send :include, CustomSassFunctions