require "redis"
require "rails"
require "rollbar"

require "authlogic"

module Munificent
  class Engine < ::Rails::Engine
    isolate_namespace Munificent

    logger = Rails.logger || ActiveSupport::Logger.new($stdout)

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: "test/factories"
    end

    initializer "munificent.hmac" do
      require "hmac"
      HMAC.configure do |config|
        config.secret = ENV.fetch("HMAC_SECRET", nil)
      end
    end

    initializer "munificent.stripe" do
      require "stripe"
      Stripe.api_key = ENV.fetch("STRIPE_SECRET_KEY", nil)
    end

    begin
      # Expose factories to the parent app/engine
      require "factory_bot_rails"
      require_relative "./factories"
      config.factory_bot.definition_file_paths += [File.expand_path("../../test/factories", __dir__)]
    rescue LoadError
      logger.debug("One or more factory_bot files could not be required, skipping additional factory_bot configuration")
    end
  end
end
