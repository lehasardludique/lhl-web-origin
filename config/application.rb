require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LhlWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Local
    config.time_zone = 'Paris'
    config.active_record.default_timezone = :local
    # I18n
    config.i18n.available_locales = [:fr]
    config.i18n.default_locale = :fr

    if config.respond_to?(:sass)
      require "#{config.root}/lib/assets/sass_functions.rb"
    end
  end
end
