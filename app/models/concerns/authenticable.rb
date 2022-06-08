module Authenticable
  extend ActiveSupport::Concern

  included do
    acts_as_authentic do |config|
      config.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
    end
  end
end
