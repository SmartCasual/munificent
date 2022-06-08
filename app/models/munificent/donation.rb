module Munificent
  class Donation < ApplicationRecord
    belongs_to :donator, inverse_of: :donations
    belongs_to :donated_by, inverse_of: :gifted_donations, optional: true, class_name: "Donator"
    belongs_to :curated_streamer, inverse_of: :donations, optional: true
    belongs_to :fundraiser, inverse_of: :donations

    has_many :payments, inverse_of: :donation, dependent: :nullify

    has_many :charity_splits, inverse_of: :donation, dependent: :destroy
    accepts_nested_attributes_for :charity_splits

    before_save do
      if charity_splits.all? { |s| s.amount.zero? }
        self.charity_splits = []
      end
    end

    monetize :amount

    validates :amount, presence: true, "munificent/donation_amount": true

    aasm column: :state do
      state :pending, initial: true
      state :cancelled
      state :paid
      state :fulfilled

      event :cancel do
        transitions from: :pending, to: :cancelled
      end

      event :confirm_payment do
        transitions from: :pending, to: :paid
      end

      event :fulfill do
        transitions from: :paid, to: :fulfilled
      end
    end

    scope :not_pending, -> { where.not(state: "pending") }
    scope :created_before, -> (timestamp) {
      where("created_at < ?", timestamp)
    }

    def charity_name
      charity&.name
    end

    def donator_name
      super || I18n.t("common.abstract.anonymous")
    end
  end
end
