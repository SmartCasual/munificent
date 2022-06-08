require "hmac"

module Munificent
  class Donator < ApplicationRecord
    include Authenticable

    attr_accessor :password_confirmation
    attr_writer :require_password

    def require_password?
      !!@require_password
    end

    validates :password,
      presence: true,
      confirmation: true,
      length: { minimum: 10 },
      if: :require_password?

    validate :email_address, -> {
      if email_address.present? && self.class.confirmed.where.not(id:).exists?(email_address:)
        errors.add(:email_address, :taken)
      end
    }

    validates(:email_address,
      uniqueness: { allow_nil: true },
      format: { with: Munificent::EMAIL_ADDRESS_REGEX, allow_nil: true },
    )

    scope :confirmed, -> { where(confirmed: true) }

    has_many :donations, inverse_of: :donator, dependent: :nullify
    has_many :gifted_donations, inverse_of: :donated_by, dependent: :nullify, class_name: "Donation",
                                foreign_key: "donated_by_id"
    has_many :donator_bundles, inverse_of: :donator, dependent: :nullify
    has_many :bundles, through: :donator_bundles
    has_many :donator_bundle_tiers, through: :donator_bundles

    has_many :curated_streamer_administrators, dependent: :destroy, inverse_of: :donator
    has_many :curated_streamers, through: :curated_streamer_administrators

    validates :twitch_id, uniqueness: true, allow_nil: true

    def self.create_from_omniauth!(auth_hash)
      case (provider = auth_hash["provider"])
      when "twitch"
        Donator.create!(
          chosen_name: auth_hash.dig("info", "nickname"),
          email_address: auth_hash.dig("info", "email"),
          name: auth_hash.dig("info", "name"),
          twitch_id: auth_hash["uid"],
        )
      else
        raise "Unsupported provider: #{provider}"
      end
    end

    def email_address=(new_email_address)
      super(new_email_address.presence)
      @token_with_email_address = nil
    end

    def total_donations(fundraiser: nil)
      if fundraiser
        donations.where(fundraiser:)
      else
        donations
      end.map(&:amount).reduce(Money.new(0), :+)
    end

    def token
      @token ||= HMAC::Generator
        .new(context: "sessions")
        .generate(id:)
    end

    def token_with_email_address
      @token_with_email_address ||= HMAC::Generator
        .new(context: "sessions")
        .generate(id:, extra_fields: { email_address: })
    end

    def display_name(current_donator: nil)
      return I18n.t("common.abstract.you") if current_donator == self

      chosen_name.presence || name.presence || I18n.t("common.abstract.anonymous")
    end

    def anonymous?
      name.blank? && chosen_name.blank?
    end

    def twitch_connected?
      twitch_id.present?
    end

    def no_identifying_marks?
      email_address.blank? && twitch_id.blank?
    end

    def confirm
      return unless confirmed? || unconfirmed_email_address.present?

      update(
        confirmed: true,
        email_address: unconfirmed_email_address,
        unconfirmed_email_address: nil,
      )
    end
  end
end
