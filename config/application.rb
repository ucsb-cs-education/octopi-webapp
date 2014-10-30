require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OctopiWebapp
  class Application < Rails::Application
    config.autoload_paths += Dir[
        Rails.root.join('lib'),
        Rails.root.join('app', 'models', 'ckeditor'),
        Rails.root.join('app', 'models', 'curriculum', 'page'),
        Rails.root.join('app', 'models', 'curriculum', 'tasks'),
        Rails.root.join('app', 'models', 'curriculum'),
        Rails.root.join('app', 'models', 'ckeditor'),
        Rails.root.join('app', 'models', 'laplaya_file')]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.action_controller.include_all_helpers = false

    config.browserify_rails.commandline_options = '-t coffeeify --extension=".js.coffee"' if config.respond_to? :browserify_rails
    config.generators do |g|
      g.test_framework :rspec
    end
    require 'rails/generators'
    Rails::Generators.fallbacks[:rspec] = :test_unit
    PaperTrail.enabled = false

  end
end
