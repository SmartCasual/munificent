require_relative "lib/munificent/version"

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 3.1"

  spec.name        = "munificent"
  spec.version     = Munificent::VERSION
  spec.authors     = ["Elliot Crosby-McCullough"]
  spec.email       = ["elliot@smart-casual.com"]
  spec.homepage    = "https://github.com/SmartCasual/munificent"
  spec.summary     = "The core of Munificent, a game-bundle fundraising platform."
  spec.license     = "CC-BY-NC-SA-4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/#{spec.version}/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) {
    Dir[
      "{app,config,db,lib}/**/*",
      "LICENCE",
      "Rakefile",
      "README.md",
      "munificent.gemspec",
      "test/factories/**/*_factory.rb",
      "test/support/aasm_factories.rb",
    ]
  }

  spec.add_dependency "aasm", "~> 5.2"
  spec.add_dependency "after_commit_everywhere", "~> 1.1"
  spec.add_dependency "authlogic", "~> 6.4"
  spec.add_dependency "aws-sdk-kms", "~> 1.53" # AWS KMS support for `kms_encrypted`
  spec.add_dependency "aws-sdk-rails", "~> 3.6"
  spec.add_dependency "blind_index", "~> 2.3" # Encrypted query support for `lockbox`
  spec.add_dependency "devise", "~> 4.8"
  spec.add_dependency "factory_bot", "~> 6.2"
  spec.add_dependency "factory_bot_namespaced_factories", "~> 0.1"
  spec.add_dependency "factory_bot_rails", "~> 6.2"
  spec.add_dependency "faraday", "~> 2.2"
  spec.add_dependency "faraday-retry", "~> 1.0"
  spec.add_dependency "hmac", "~> 2.1"
  spec.add_dependency "kms_encrypted", "~> 1.4" # KMS support for `lockbox`
  spec.add_dependency "lockbox", "~> 0.6" # Game key encryption
  spec.add_dependency "monetize", "~> 1.12"
  spec.add_dependency "money-rails", "~> 1.15"
  spec.add_dependency "net-smtp", "~> 0.3"
  spec.add_dependency "omniauth", "~> 2.0"
  spec.add_dependency "omniauth-rails_csrf_protection", "~> 1.0"
  spec.add_dependency "omniauth-token", "~> 1.0"
  spec.add_dependency "omniauth-twitch_smartcasual", "~> 1.1"
  spec.add_dependency "paypal-rest", "~> 1.1"
  spec.add_dependency "rails", "~> 7.0"
  spec.add_dependency "redis", "~> 4.6"
  spec.add_dependency "rollbar", "~> 3.3"
  spec.add_dependency "scrypt", "~> 3.0"
  spec.add_dependency "sidekiq", "~> 6.4"
  spec.add_dependency "stripe", "~> 5.43"
end
