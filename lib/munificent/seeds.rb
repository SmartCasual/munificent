# rubocop:disable Rails/Output
module Munificent
  class Seeds
    def self.run
      puts "Creating active fundraisers"
      wwf = Fundraiser.create!(name: "WWF Manatee Matinée (London)", main_currency: "GBP")
      msf = Fundraiser.create!(name: "MSF Gala (Paris)", main_currency: "EUR")

      [wwf, msf].each do |fundraiser|
        puts "Populating the fundraiser #{fundraiser.name}"
        fundraiser.activate!

        puts "Creating bundle"
        bundle = Bundle.create!(
          name: "Test bundle",
          fundraiser:,
          state: "live",
        )

        bundle.highest_tier.update(price_decimals: 25_00)
        bundle.highest_tier.bundle_tier_games.create!(game: Game.find_or_initialize_by(name: "The Witness"))

        tier = bundle.bundle_tiers.create!(price_decimals: 10_00, price_currency: fundraiser.main_currency)

        tier.bundle_tier_games.create!(game: Game.find_or_initialize_by(name: "Doom"))
        tier.bundle_tier_games.create!(game: Game.find_or_initialize_by(name: "Duke Nukem Forever"))

        Game.all.each do |game|
          puts "Adding 100 keys for #{game.name}"
          100.times do
            game.keys.create(
              code: SecureRandom.uuid,
              fundraiser:,
            )
          end
        end
      end

      puts "Creating charities"
      Charity.create(name: "Help the Penguins", fundraisers: [wwf])
      Charity.create(name: "World Wildlife Foundation", fundraisers: [wwf])
      Charity.create(name: "Vets Without Borders", fundraisers: [wwf, msf])
      Charity.create(name: "Médecins Sans Frontières", fundraisers: [msf])
    end
  end
end
# rubocop:enable Rails/Output
