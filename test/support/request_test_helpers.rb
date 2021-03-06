module RequestTestHelpers
  # https://stripe.com/docs/webhooks/signatures#verify-manually
  def valid_signature(timestamp, payload, stripe_webhook_secret_key = nil)
    "t=#{timestamp},v1=#{hmac(timestamp, payload, stripe_webhook_secret_key || ENV.fetch('STRIPE_WEBHOOK_SECRET_KEY', nil))}"
  end

  def hmac(timestamp, payload, secret_key)
    OpenSSL::HMAC
      .new(secret_key, OpenSSL::Digest.new("SHA256"))
      .update([timestamp, JSON.dump(JSON.parse(payload))].join("."))
      .hexdigest
  end

  def simulate_stripe_webhook(payload:, timestamp:, expect: 200, signature: nil, stripe_webhook_secret_key: nil)
    post_json("/stripe/webhook", JSON.parse(payload),
      headers: {
        "HTTP_STRIPE_SIGNATURE" => (signature || valid_signature(timestamp, payload, stripe_webhook_secret_key)),
      },
      expect:,
      as: :json,
    )
  end

  def post_json(path, params, headers: {}, expect: 200, as: nil)
    session = ActionDispatch::Integration::Session.new(Rails.application)

    status = session.post(path,
      params:,
      headers: { "ACCEPT" => "application/json" }.merge(headers),
      as:,
    )
    expect(status).to eq(expect)

    session.response
  end

  def stripe_webhook_payload(event_type:, object: "{}", timestamp: Time.zone.now.to_i)
    <<~JSON
      {
        "created": #{timestamp},
        "livemode": true,
        "id": "evt_00000000000000",
        "type": "#{event_type}",
        "object": "event",
        "request": null,
        "pending_webhooks": 1,
        "api_version": "2020-08-27",
        "data": {
          "object": #{object}
        }
      }
    JSON
  end

  def stripe_payment_intent_object(amount: "2500", currency: "gbp", payment_intent_id: "pi_00000000000000", email_address: nil)
    <<~JSON
      {
        "id": "#{payment_intent_id}",
        "object": "payment_intent",
        "amount": #{amount},
        "amount_capturable": 0,
        "amount_received": #{amount},
        "application": null,
        "application_fee_amount": null,
        "canceled_at": null,
        "cancellation_reason": null,
        "capture_method": "automatic",
        "charges": {
          "object": "list",
          "data": [
            {
              "id": "ch_00000000000000",
              "object": "charge",
              "amount": #{amount},
              "amount_captured": #{amount},
              "amount_refunded": 0,
              "application": null,
              "application_fee": null,
              "application_fee_amount": null,
              "balance_transaction": null,
              "billing_details": {
                "address": {
                  "city": null,
                  "country": null,
                  "line1": null,
                  "line2": null,
                  "postal_code": null,
                  "state": null
                },
                "email": #{email_address.nil? ? 'null' : %("#{email_address}")},
                "name": null,
                "phone": null
              },
              "calculated_statement_descriptor": null,
              "captured": true,
              "created": 1556596206,
              "currency": "#{currency.downcase}",
              "customer": null,
              "description": "My First Test Charge (created for API docs)",
              "disputed": false,
              "failure_code": null,
              "failure_message": null,
              "fraud_details": {
              },
              "invoice": null,
              "livemode": false,
              "metadata": {
              },
              "on_behalf_of": null,
              "order": null,
              "outcome": null,
              "paid": true,
              "payment_intent": "#{payment_intent_id}",
              "payment_method": "pm_00000000000000",
              "payment_method_details": {
                "card": {
                  "brand": "visa",
                  "checks": {
                    "address_line1_check": null,
                    "address_postal_code_check": null,
                    "cvc_check": null
                  },
                  "country": "US",
                  "exp_month": 8,
                  "exp_year": 2020,
                  "fingerprint": "0Kibh5fAgbiiwPEL",
                  "funding": "credit",
                  "installments": null,
                  "last4": "4242",
                  "network": "visa",
                  "three_d_secure": null,
                  "wallet": null
                },
                "type": "card"
              },
              "receipt_email": null,
              "receipt_number": "1335-4536",
              "receipt_url": "https://pay.stripe.com/receipts/acct_103fq42x6R10KRrh/ch_1EUmyp2t6R10KRrh1UkloFX6/rcpt_EykTJJ8hrfu9RtPsuXGXGzrExvgxrv9",
              "refunded": false,
              "refunds": {
                "object": "list",
                "data": [
                ],
                "has_more": false,
                "url": "/v1/charges/ch_1EUmyp2x6R10KRrh4UkloFX6/refunds"
              },
              "review": null,
              "shipping": null,
              "source_transfer": null,
              "statement_descriptor": null,
              "statement_descriptor_suffix": null,
              "status": "succeeded",
              "transfer_data": null,
              "transfer_group": null
            }
          ],
          "has_more": false,
          "url": "/v1/charges?payment_intent=pi_1EUmyo3x6R10KRrhXhPL4oAI"
        },
        "client_secret": "pi_1EUmyo2x6R10LRrhXhPL4oAI_secret_rMQk5jrC96aWY79W7KWO4cKfT",
        "confirmation_method": "automatic",
        "created": 1556596206,
        "currency": "#{currency.downcase}",
        "customer": null,
        "description": null,
        "invoice": null,
        "last_payment_error": null,
        "livemode": false,
        "metadata": {
        },
        "next_action": null,
        "on_behalf_of": null,
        "payment_method": "pm_00000000000000",
        "payment_method_options": {
        },
        "payment_method_types": [
          "card"
        ],
        "receipt_email": null,
        "review": null,
        "setup_future_usage": null,
        "shipping": null,
        "statement_descriptor": null,
        "statement_descriptor_suffix": null,
        "status": "succeeded",
        "transfer_data": null,
        "transfer_group": null
      }
    JSON
  end

  def stub_stripe_session_creation(amount:, order_id: SecureRandom.uuid, payment_intent_id: "pi_#{SecureRandom.hex}", email_address: nil)
    allow(Stripe::Checkout::Session).to receive(:create)
      .with(
        hash_including(
          line_items: [
            hash_including(
              price_data: hash_including(
                currency: amount.currency.iso_code,
                unit_amount: amount.cents,
              ),
            ),
          ],
        ),
      )
      .and_return(
        Stripe::Checkout::Session.new(id: order_id).tap { |s|
          s.payment_intent = payment_intent_id
          s.customer_email = email_address
        },
      )

    payment_intent_id
  end

  def stub_paypal_order_creation(amount:, order_id: SecureRandom.uuid)
    allow(Paypal::REST).to receive(:create_order)
      .with(
        hash_including(
          purchase_units: [
            hash_including(
              amount: {
                currency_code: amount.currency.iso_code,
                value: amount.format(symbol: false),
              },
            ),
          ],
        ),
      ).and_return(order_id)

    order_id
  end

  def stub_paypal_payment_capture(order_id:, email_address: nil)
    allow(Paypal::REST).to receive(:capture_payment_for_order)
      .with(order_id, full_response: true)
      .and_return(payer: { email_address: })
  end

  def stub_twitch_auth(auth_hash)
    orig_test_mode = OmniAuth.config.test_mode
    orig_mock_auth = OmniAuth.config.mock_auth[:twitch]

    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitch] = OmniAuth::AuthHash.new(
      auth_hash.merge(provider: "twitch"),
    )

    yield

    OmniAuth.config.test_mode = orig_test_mode
    OmniAuth.config.mock_auth[:twitch] = orig_mock_auth
  end
end
