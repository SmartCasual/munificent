module Munificent
  class Payment < ApplicationRecord
    belongs_to :donation, optional: true, inverse_of: :payments

    class << self
      def create_and_assign(amount:, currency:, stripe_payment_intent_id: nil, paypal_order_id: nil)
        if stripe_payment_intent_id.nil? && paypal_order_id.nil?
          raise ArgumentError,
  "Either stripe_payment_intent_id or paypal_order_id must be provided"
        end

        params = {
          amount_decimals: amount,
          amount_currency: currency,
        }

        if stripe_payment_intent_id
          unless (payment = Payment.find_by(stripe_payment_intent_id:))
            payment = Payment.create!(stripe_payment_intent_id:, **params)
          end

          PaymentAssignmentJob.perform_later(payment.id, provider: :stripe)
        else
          unless (payment = Payment.find_by(paypal_order_id:))
            payment = Payment.create!(paypal_order_id:, **params)
          end

          PaymentAssignmentJob.perform_later(payment.id, provider: :paypal)
        end
      end
    end
  end
end
