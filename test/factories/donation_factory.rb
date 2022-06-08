require_relative "../support/aasm_factories"

Munificent::Factories.define :donation do
  donator
  amount { Money.new(25_000) }
  message { "Some standard message" }
  sequence(:stripe_payment_intent_id) { |n| "stripe_payment_intent_id_#{n}" }

  fundraiser { Munificent::Fundraiser.active.first || association(:fundraiser, :active) }

  transient do
    charity_split { {} }
  end

  AASMFactories.init(self, @definition)

  after(:build) do |donation, evaluator|
    evaluator.charity_split.each do |charity, split_amount|
      donation.charity_splits.build(
        donation:,
        charity:,
        amount: split_amount,
      )
    end
  end
end
