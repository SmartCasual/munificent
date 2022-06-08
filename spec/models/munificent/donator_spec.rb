RSpec.describe Munificent::Donator do
  subject(:donator) { create(:donator) }

  describe "#total_donations(fundraiser: nil)" do
    let(:fundraiser) { create(:fundraiser) }

    before do
      create(:donation,
        donator:,
        amount: Money.new(10_00, "USD"),
      )
      create(:donation,
        donator:,
        amount: Money.new(10_00, "GBP"),
      )
      create(:donation,
        donator:,
        amount: Money.new(10_00, "EUR"),
        fundraiser:,
      )
    end

    it "sums all donations into the primary currency" do
      # TODO: Make this adapt with changing exchange rates
      expect(donator.total_donations).to eq(Money.new(25_85, "GBP"))
    end

    it "sums all donations for the given fundraiser (if any)" do
      expect(donator.total_donations(fundraiser:)).to eq(Money.new(10_00, "EUR"))
    end
  end

  describe "token generation" do
    let(:sha256_digest) { OpenSSL::Digest.new("SHA256") }
    let(:hmac_secret) { SecureRandom.uuid }

    around do |example|
      with_env("HMAC_SECRET" => hmac_secret) do
        example.run
      end
    end

    describe "#token" do
      it "encodes the user's ID with SHA256" do
        expect(donator.token).to eq(
          HMAC::Generator.new(context: "sessions").generate(
            id: donator.id.to_s,
          ),
        )
      end

      it "does not change when the email address changes" do
        expect { donator.email_address = "new@example.com" }.not_to change(donator, :token)
      end
    end

    describe "#token_with_email_address" do
      it "encodes the user's ID with SHA256" do
        expect(donator.token_with_email_address).to eq(
          HMAC::Generator.new(context: "sessions").generate(
            id: donator.id.to_s,
            extra_fields: { email_address: donator.email_address },
          ),
        )
      end

      it "changes when the email address changes" do
        expect { donator.email_address = "new@example.com" }.to change(donator, :token_with_email_address)
      end
    end
  end

  describe ".create_from_omniauth!(auth_hash)" do
    subject(:donator) { described_class.create_from_omniauth!(auth_hash) }

    let(:auth_hash) do
      {
        "provider" => "twitch",
        "uid" => provider_uid,
        "info" => {
          "name" => "John Doe",
          "nickname" => "jdoe",
          "email" => "test@example.com",
        },
      }
    end

    let(:provider_uid) { "12345" }

    context "with a valid provider (twitch)" do
      it "creates a new donator" do
        expect { donator }.to change(described_class, :count).by(1)
      end

      it "returns the new donator" do
        expect(donator).to be_a(described_class)
      end

      it "sets the donator's chosen name" do
        expect(donator.chosen_name).to eq(auth_hash["info"]["nickname"])
      end

      it "sets the donator's email address" do
        expect(donator.email_address).to eq(auth_hash["info"]["email"])
      end

      it "sets the donator's twitch uid" do
        expect(donator.twitch_id).to eq(auth_hash["uid"])
      end
    end

    context "with an invalid provider" do
      let(:auth_hash) { { "provider" => "invalid", "uid" => "12345" } }

      it "raises an error" do
        expect { donator }.to raise_error("Unsupported provider: invalid")
      end
    end

    context "with a provider uid that already exists" do
      before do
        create(:donator, twitch_id: provider_uid)
      end

      it "raises an error" do
        expect { donator }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Twitch ID is taken")
      end
    end
  end

  describe "#display_name(donator:)" do
    subject(:result) { donator.display_name(current_donator:) }

    let(:donator) { create(:donator, name:, chosen_name:) }
    let(:current_donator) { nil }

    context "if the donator is anonymous" do
      context "with nil names" do
        let(:name) { nil }
        let(:chosen_name) { nil }

        it { is_expected.to eq("Anonymous") }
      end

      context "with blank names" do
        let(:name) { "" }
        let(:chosen_name) { "" }

        it { is_expected.to eq("Anonymous") }
      end
    end

    context "if the donator has a name" do
      let(:name) { "John Doe" }
      let(:chosen_name) { nil }

      it { is_expected.to eq("John Doe") }

      context "if the chosen name is present but blank" do
        let(:chosen_name) { "" }

        it "still returns the name" do
          expect(result).to eq("John Doe")
        end
      end
    end

    context "if the donator has a chosen name" do
      let(:name) { nil }
      let(:chosen_name) { "jdoe" }

      it { is_expected.to eq("jdoe") }
    end

    context "if the donator has a name and a chosen name" do
      let(:name) { "John Doe" }
      let(:chosen_name) { "jdoe" }

      it "returns the donator's chosen name" do
        expect(result).to eq("jdoe")
      end
    end

    context "if the donator is the same as the other donator" do
      let(:current_donator) { donator }
      let(:name) { "John Doe" }
      let(:chosen_name) { "jdoe" }

      it { is_expected.to eq("You") }
    end
  end

  describe ".confirm" do
    subject(:donator) { create(:donator, email_address:, unconfirmed_email_address:, confirmed:) }

    let(:new_email_address) { "new-test@example.com" }

    context "when the donator is unconfirmed" do
      let(:confirmed) { false }
      let(:email_address) { nil }

      context "and the donator's unconfirmed email address is blank" do
        let(:unconfirmed_email_address) { nil }

        it "returns falsey" do
          expect(donator.confirm).to be_falsey
        end
      end

      context "and the donator's unconfirmed email address is present" do
        let(:unconfirmed_email_address) { "test@example.com" }

        it "confirms the donator" do
          expect { donator.confirm }.to change(donator, :confirmed).from(false).to(true)
        end

        it "moves the email address over on confirmation" do
          expect(donator.email_address).to be_nil
          expect(donator.unconfirmed_email_address).to eq(unconfirmed_email_address)

          donator.confirm
          donator.reload

          expect(donator.email_address).to eq(unconfirmed_email_address)
          expect(donator.unconfirmed_email_address).to be_nil
        end
      end
    end
  end

  describe "#email_address" do
    let(:donator) { build("munificent_donator", :with_email_address) }

    it "is valid with a valid email address" do
      donator.email_address = "valid@example.com"
      expect(donator).to be_valid
    end

    it "is invalid with an invalid email address" do
      donator.email_address = "invalid"
      expect(donator).not_to be_valid
    end
  end

  describe "#no_identifying_marks?" do
    subject { donator.no_identifying_marks? }

    context "when the donator has no identifying marks" do
      before do
        donator.update(
          email_address: nil,
          twitch_id: nil,
        )
      end

      it { is_expected.to be(true) }
    end

    context "when the donator has an unconfirmed email address" do
      before do
        donator.update(unconfirmed_email_address: "test@example.com")
      end

      it { is_expected.to be(true) }
    end

    context "when the donator has a confirmed email address" do
      before do
        donator.update(confirmed: true, email_address: "test@example.com")
      end

      it { is_expected.to be(false) }
    end

    context "when the donator has a Twitch ID" do
      before do
        donator.update(twitch_id: "123")
      end

      it { is_expected.to be(false) }
    end
  end
end
