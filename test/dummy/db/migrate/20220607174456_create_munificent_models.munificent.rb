# This migration comes from munificent (originally 20220525220035)
class CreateMunificentModels < ActiveRecord::Migration[7.0]
  def change
    create_table :munificent_donators  do |t|
      t.string :chosen_name
      t.string :name

      t.string :stripe_customer_id, index: { unique: true }
      t.string :twitch_id, index: { unique: true }

      # Email address and login
      t.string :email_address, index: { unique: true, where: "confirmed = false" }
      t.string :unconfirmed_email_address

      # Authlogic::ActsAsAuthentic::Password
      t.string :crypted_password
      t.string :password_salt

      # Authlogic::ActsAsAuthentic::PersistenceToken
      t.string :persistence_token, index: { unique: true }

      # Authlogic::ActsAsAuthentic::SingleAccessToken
      t.string :single_access_token, index: { unique: true }

      # Authlogic::ActsAsAuthentic::PerishableToken
      t.string :perishable_token, index: { unique: true }

      # See "Magic Columns" in Authlogic::Session::Base
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.datetime :last_request_at
      t.integer :failed_login_count, default: 0, null: false
      t.integer :login_count, default: 0, null: false
      t.string :current_login_ip
      t.string :last_login_ip

      # See "Magic States" in Authlogic::Session::Base
      t.boolean :active, default: false
      t.boolean :approved, default: false
      t.boolean :confirmed, default: false

      t.timestamps
    end

    create_table :munificent_curated_streamers  do |t|
      t.string :twitch_username, null: false, index: true, unique: true

      t.timestamps
    end

    create_table :munificent_fundraisers  do |t|
      t.datetime :ends_at
      t.datetime :starts_at
      t.string :main_currency, default: "GBP", null: false
      t.string :name, null: false
      t.string :overpayment_mode, null: false, default: "pro_bono"
      t.string :short_url
      t.string :state, null: false, default: "inactive"
      t.text :description

      t.timestamps
    end

    create_table :munificent_charities  do |t|
      t.string :name, index: true, null: false
      t.text :description

      t.timestamps
    end

    create_table :munificent_games  do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end

    create_table :munificent_donations  do |t|
      t.monetize :amount
      t.string :donator_name
      t.string :message

      t.string :state, null: false, default: "pending"

      t.string :paypal_order_id
      t.string :stripe_payment_intent_id, index: { unique: true }
      t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"

      t.references :donator, null: false, foreign_key: { to_table: :munificent_donators }
      t.references :donated_by, null: true, foreign_key: { to_table: :munificent_donators }
      t.references :curated_streamer, null: true, foreign_key: { to_table: :munificent_curated_streamers }
      t.references :fundraiser, index: true, foreign_key: { to_table: :munificent_fundraisers }

      t.timestamps
    end

    create_table :munificent_payments  do |t|
      t.monetize :amount

      t.references :donation, null: true, foreign_key: { to_table: :munificent_donations }

      t.string :stripe_payment_intent_id, unique: true
      t.string :paypal_order_id
      t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"

      t.timestamps
    end

    create_table :munificent_charity_splits  do |t|
      t.monetize :amount

      t.references :donation, null: true, foreign_key: { to_table: :munificent_donations }
      t.references :charity, null: false, foreign_key: { to_table: :munificent_charities }

      t.timestamps
    end

    create_table :munificent_bundles  do |t|
      t.string :name, null: false

      t.string :state, null: false, default: "draft"

      t.references :fundraiser, index: true, null: false, foreign_key: { to_table: :munificent_fundraisers }
      t.index [:name, :fundraiser_id], unique: true

      t.timestamps
    end

    create_table :munificent_donator_bundles  do |t|
      t.references :donator, null: false, foreign_key: { to_table: :munificent_donators }
      t.references :bundle, null: false, foreign_key: { to_table: :munificent_bundles }

      t.timestamps
    end

    create_table :munificent_bundle_tiers  do |t|
      t.datetime :ends_at
      t.datetime :starts_at
      t.monetize :price
      t.string :name

      t.references :bundle, null: false, index: true, foreign_key: { to_table: :munificent_bundles }

      t.timestamps
    end

    create_table :munificent_bundle_tier_games  do |t|
      t.references :bundle_tier, null: false, foreign_key: { to_table: :munificent_bundle_tiers }
      t.references :game, null: false, foreign_key: { to_table: :munificent_games }

      t.timestamps
    end

    create_table :munificent_donator_bundle_tiers  do |t|
      t.references :donator_bundle,
        null: false,
        index: { name: "donator_bundle_tier_donator_bundle_id_index" },
        foreign_key: { to_table: :munificent_donator_bundles }
      t.references :bundle_tier,
        null: false,
        index: { name: "donator_bundle_tier_bundle_tier_id_index" },
        foreign_key: { to_table: :munificent_bundle_tiers }

      t.boolean :unlocked, default: false, null: false

      t.timestamps
    end

    create_table :munificent_keys  do |t|
      t.references :game, null: false, foreign_key: { to_table: :munificent_games }
      t.references :donator_bundle_tier, null: true, foreign_key: { to_table: :munificent_donator_bundle_tiers }
      t.references :fundraiser, index: true, foreign_key: { to_table: :munificent_fundraisers }

      # Ciphertext
      t.text :code_ciphertext

      # Encryption key
      t.text :encrypted_kms_key

      # Blind index
      t.string :code_bidx, index: { unique: true }

      t.index [:donator_bundle_tier_id, :game_id], unique: true, name: "donator_bundle_tier_game_idx"

      t.timestamps
    end

    create_table :munificent_charity_fundraisers  do |t|
      t.references :charity, foreign_key: { to_table: :munificent_charities }
      t.references :fundraiser,
        index: { name: "charity_fundraiser_fundraiser_id_index" },
        foreign_key: { to_table: :munificent_fundraisers }

      t.timestamps
    end

    create_table :munificent_curated_streamer_administrators  do |t|
      t.references :curated_streamer,
        null: false,
        index: { name: "curated_streamer_administrator_curated_streamer_id_index" },
        foreign_key: { to_table: :munificent_curated_streamers }
      t.references :donator,
        null: false,
        index: { name: "curated_streamer_administrator_donator_id_index" },
        foreign_key: { to_table: :munificent_donators }

      t.index [:curated_streamer_id, :donator_id], unique: true, name: "curated_streamer_donator_index"

      t.timestamps
    end
  end
end
