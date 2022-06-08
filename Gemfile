source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in munificent.gemspec.
gemspec

gem "byebug", "~> 11.1", platforms: %i[mri mingw x64_mingw]
gem "pg", "~> 1.3"
gem "puma", "~> 5.6"
gem "rubocop", "~> 1.25"
gem "rubocop-rails", "~> 2.13"
gem "rubocop-rake", "~> 0.6"
gem "rubocop-rspec", "~> 2.7"

group :test do
  gem "climate_control", "~> 1.0"
  gem "database_cleaner", "~> 2.0"
  gem "factory_bot", "~> 6.2"
  gem "factory_bot_rails", "~> 6.2"
  gem "rspec-rails", "~> 5.0"
  gem "timecop", "~> 0.9"
  gem "vcr", "~> 6.1"
  gem "webmock", "~> 3.14"
end
