Munificent::Factories.define :bundle_tier_game do
  bundle_tier
  association(:game, :with_keys)
end
