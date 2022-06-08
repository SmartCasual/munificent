RSpec.describe Munificent::StripePaymentSweeper do
  subject(:sweeper) { described_class }

  describe "#run", vcr: true do
    before do
      allow(Munificent::Payment).to receive(:create_and_assign)
    end

    it "creates and assigns payments for each successful Stripe payment" do
      sweeper.run

      expect(Munificent::Payment).to have_received(:create_and_assign).exactly(51).times
        .with(
          amount: instance_of(Integer),
          currency: /^\w{3}$/,
          stripe_payment_intent_id: /^pi_[a-z0-9]+$/i,
        )
    end
  end
end
