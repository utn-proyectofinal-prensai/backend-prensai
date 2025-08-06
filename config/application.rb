require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module BackendPrensaiRails
  class Application < Rails::Application
    config.load_defaults 8.0
    config.autoload_lib(ignore: %w[assets tasks])
    config.time_zone = "UTC"
    config.api_only = true
    
    # Deshabilitar tzinfo completamente
    config.after_initialize do
      ENV["TZINFO_DATA_PATH"] = nil
      ENV["TZINFO_DATA_SOURCE"] = "none"
    end
  end
end