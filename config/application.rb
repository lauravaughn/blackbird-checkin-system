require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

module BlackbirdCheckin
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # Time zone
    config.time_zone = 'Eastern Time (US & Canada)'
    
    # CORS settings for API
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :post, :patch, :put, :delete]
      end
    end
  end
end