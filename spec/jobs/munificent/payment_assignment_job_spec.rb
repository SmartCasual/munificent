RSpec.describe Munificent::PaymentAssignmentJob, queue_type: :test do
  subject(:job) { described_class.new }

  let(:stripe_payment_intent_id) { "pi_#{SecureRandom.uuid}" }

  let(:payment) do
    create("munificent_payment",
      stripe_payment_intent_id:,
    )
  end
  let!(:donation) do
    create("munificent_donation",
      stripe_payment_intent_id:,
      donator:,
    )
  end

  let(:donator) { create("munificent_donator") }

  let(:payment_id) { payment.id }

  it "links the payment and the donation" do
    job.perform(payment_id, provider: :stripe)
    expect(payment.reload.donation).to eq(donation)
  end

  it "marks the donation as paid" do
    job.perform(payment_id, provider: :stripe)
    expect(donation.reload).to be_paid
  end

  it "triggers a donator bundle assignment job for the donator" do
    job.perform(payment_id, provider: :stripe)
    expect(Munificent::DonatorBundleAssignmentJob).to have_been_enqueued.with(donator.id)
  end

  context "if the payment isn't found" do
    let(:payment_id) { 1234 }

    it "errors and does nothing" do
      expect {
        job.perform(payment_id, provider: :stripe)
      }.to raise_error(ActiveRecord::RecordNotFound)

      expect(Munificent::DonatorBundleAssignmentJob).not_to have_been_enqueued
    end
  end

  context "if the donation isn't found" do
    before do
      Munificent::Donation.destroy_all
    end

    it "reports the error and does nothing" do
      job.perform(payment_id, provider: :stripe)
      # TODO: Check for error tracking report

      expect(Munificent::DonatorBundleAssignmentJob).not_to have_been_enqueued
    end
  end

  context "if the donation is already linked to the payment" do
    before do
      payment.update(donation:)
    end

    it "remains linked to the payment" do
      job.perform(payment_id, provider: :stripe)
      expect(payment.reload.donation).to eq(donation)
    end

    it "marks the donation as paid" do
      job.perform(payment_id, provider: :stripe)
      expect(donation.reload).to be_paid
    end

    it "triggers a donator bundle assignment job for the donator" do
      job.perform(payment_id, provider: :stripe)
      expect(Munificent::DonatorBundleAssignmentJob).to have_been_enqueued.with(donator.id)
    end
  end

  context "if the donation is already marked as paid" do
    before do
      donation.confirm_payment!
    end

    it "remains marked as paid" do
      job.perform(payment_id, provider: :stripe)
      expect(donation.reload).to be_paid
    end

    it "links the payment and the donation" do
      job.perform(payment_id, provider: :stripe)
      expect(payment.reload.donation).to eq(donation)
    end

    it "does not trigger a donator bundle assignment job for the donator" do
      job.perform(payment_id, provider: :stripe)
      expect(Munificent::DonatorBundleAssignmentJob).not_to have_been_enqueued
    end
  end
end
