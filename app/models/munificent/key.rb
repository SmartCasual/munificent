module Munificent
  require "aws-sdk-kms"
  require "aws-sdk-rails"
  require "blind_index"
  require "kms_encrypted"
  require "lockbox"

  class Key < ApplicationRecord
    has_kms_key

    lockbox_encrypts :code, key: :kms_key
    blind_index :code

    belongs_to :game, inverse_of: :keys
    belongs_to :donator_bundle_tier, inverse_of: :keys, optional: true
    belongs_to :fundraiser, inverse_of: :keys, optional: true

    validates :code, presence: true

    scope :unassigned, -> { where(donator_bundle_tier: nil) }
    scope :assigned, -> { where.not(donator_bundle_tier: nil) }

    after_commit on: :create do
      KeyAssignment::RequestProcessor.recheck_database
    end

    def assigned?
      donator_bundle_tier_id.present?
    end
  end
end
