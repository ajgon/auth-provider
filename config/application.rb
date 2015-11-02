require File.expand_path('../boot', __FILE__)

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
# require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Auth
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += %W(#{config.root}/app/models/providers)

    config.omniauth_providers =
      YAML.load_file(Rails.root.join('config', 'omniauth-providers.yml')).select { |_name, opts| opts['enabled'] }

    config.middleware.insert_before 0, 'Rack::Cors' do
      if_callback = proc do |env|
        next true if Rack::Utils.parse_nested_query(env['QUERY_STRING'])['response_type'].to_s.downcase == 'code'
        ::Application.with_allowed_cors(env['HTTP_ORIGIN']).map do |u|
          "#{u.slug}.#{ActionMailer::Base.default_url_options[:host]}"
        end.include?(env['HTTP_HOST'])
      end

      allow do
        origins '*'
        resource '/login/*', headers: :any, methods: [:get, :post, :delete, :patch], credentials: true, if: if_callback
        resource '/widget', headers: :any, methods: [:get, :post, :delete, :patch], credentials: true, if: if_callback
      end
    end
  end
end
