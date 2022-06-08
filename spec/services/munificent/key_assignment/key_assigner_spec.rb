RSpec.describe Munificent::KeyAssignment::KeyAssigner do
  subject(:service) { described_class.new(key_manager:) }

  let(:key_manager) { instance_double(Munificent::KeyAssignment::KeyManager) }

  let(:donator) { create("munificent_donator") }
  let(:donator_bundle) { create("munificent_donator_bundle", donator:) }
  let(:donator_bundle_tier) { create("munificent_donator_bundle_tier", donator_bundle:, unlocked: true) }

  let(:game) { donator_bundle_tier.bundle_tier.games.first }

  before do
    allow(key_manager).to receive(:key_assigned?)
      .and_return(false)

    allow_any_instance_of(Munificent::DonatorBundleTier).to receive(:trigger_fulfillment)
  end

  context "when it gets a lock on an unassigned key" do
    let(:key) { create("munificent_key", game:) }

    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game, fundraiser: anything).and_yield(key)
    end

    it "assigns the key" do
      service.assign(donator_bundle_tier)
      expect(key.reload.donator_bundle_tier).to eq(donator_bundle_tier)
    end
  end

  context "when it fails to gets a lock on an unassigned key" do
    before do
      allow(key_manager).to receive(:lock_unassigned_key)
        .with(game, fundraiser: anything).and_yield(nil)
    end

    it "does not assign the key" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
    end
  end

  context "when the donator bundle tier is locked" do
    before do
      donator_bundle_tier.update(unlocked: false)
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
    end
  end

  context "when there's no game" do
    before do
      donator_bundle_tier.bundle_tier.games.destroy_all
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
    end
  end

  context "when a key has already been assigned" do
    before do
      allow(key_manager).to receive(:key_assigned?)
        .and_return(true)
    end

    it "does nothing" do
      service.assign(donator_bundle_tier)
      expect(donator_bundle_tier.reload.keys).to be_empty
    end
  end
end
