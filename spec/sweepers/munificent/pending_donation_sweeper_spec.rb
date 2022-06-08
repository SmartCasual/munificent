RSpec.describe Munificent::PendingDonationSweeper do
  subject(:sweeper) { described_class }

  describe "#run" do
    it "deletes pending donations older than 24 hours" do
      new_pending = create("munificent_donation", created_at: 1.hour.ago)
      old_pending = create("munificent_donation", created_at: 2.days.ago)

      sweeper.run

      expect(Munificent::Donation).to exist(id: new_pending.id)
      expect(Munificent::Donation).not_to exist(id: old_pending.id)
    end

    it "does not delete non-pending donations of any age" do
      donations = []

      donations << create("munificent_donation", :paid, created_at: 1.hour.ago)
      donations << create("munificent_donation", :paid, created_at: 2.days.ago)

      donations << create("munificent_donation", :cancelled, created_at: 1.hour.ago)
      donations << create("munificent_donation", :cancelled, created_at: 2.days.ago)

      donations << create("munificent_donation", :fulfilled, created_at: 1.hour.ago)
      donations << create("munificent_donation", :fulfilled, created_at: 2.days.ago)

      donations.each do |donation|
        expect(Munificent::Donation).to exist(id: donation.id)
      end
    end
  end
end
