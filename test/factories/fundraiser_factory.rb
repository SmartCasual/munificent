Munificent::Factories.define :fundraiser do
  sequence(:name) { |n| "Fundraiser #{n}" }

  AASMFactories.init(self, @definition)

  trait :with_live_bundle do
    bundles do
      build_list(:bundle, 1, :live)
    end
  end
end
