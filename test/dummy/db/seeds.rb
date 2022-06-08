if Rails.env.development? || ["1", "true"].include?(ENV.fetch("FORCE_SEEDS", nil))
  require "munificent/seeds"
  Munificent::Seeds.run
end
