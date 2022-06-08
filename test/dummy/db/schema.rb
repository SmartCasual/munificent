# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_06_07_174456) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "munificent_bundle_tier_games", force: :cascade do |t|
    t.bigint "bundle_tier_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_tier_id"], name: "index_munificent_bundle_tier_games_on_bundle_tier_id"
    t.index ["game_id"], name: "index_munificent_bundle_tier_games_on_game_id"
  end

  create_table "munificent_bundle_tiers", force: :cascade do |t|
    t.datetime "ends_at"
    t.datetime "starts_at"
    t.integer "price_decimals", default: 0, null: false
    t.string "price_currency", default: "GBP", null: false
    t.string "name"
    t.bigint "bundle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_id"], name: "index_munificent_bundle_tiers_on_bundle_id"
  end

  create_table "munificent_bundles", force: :cascade do |t|
    t.string "name", null: false
    t.string "state", default: "draft", null: false
    t.bigint "fundraiser_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fundraiser_id"], name: "index_munificent_bundles_on_fundraiser_id"
    t.index ["name", "fundraiser_id"], name: "index_munificent_bundles_on_name_and_fundraiser_id", unique: true
  end

  create_table "munificent_charities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_munificent_charities_on_name"
  end

  create_table "munificent_charity_fundraisers", force: :cascade do |t|
    t.bigint "charity_id"
    t.bigint "fundraiser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charity_id"], name: "index_munificent_charity_fundraisers_on_charity_id"
    t.index ["fundraiser_id"], name: "charity_fundraiser_fundraiser_id_index"
  end

  create_table "munificent_charity_splits", force: :cascade do |t|
    t.integer "amount_decimals", default: 0, null: false
    t.string "amount_currency", default: "GBP", null: false
    t.bigint "donation_id"
    t.bigint "charity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charity_id"], name: "index_munificent_charity_splits_on_charity_id"
    t.index ["donation_id"], name: "index_munificent_charity_splits_on_donation_id"
  end

  create_table "munificent_curated_streamer_administrators", force: :cascade do |t|
    t.bigint "curated_streamer_id", null: false
    t.bigint "donator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curated_streamer_id", "donator_id"], name: "curated_streamer_donator_index", unique: true
    t.index ["curated_streamer_id"], name: "curated_streamer_administrator_curated_streamer_id_index"
    t.index ["donator_id"], name: "curated_streamer_administrator_donator_id_index"
  end

  create_table "munificent_curated_streamers", force: :cascade do |t|
    t.string "twitch_username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["twitch_username"], name: "index_munificent_curated_streamers_on_twitch_username"
  end

  create_table "munificent_donations", force: :cascade do |t|
    t.integer "amount_decimals", default: 0, null: false
    t.string "amount_currency", default: "GBP", null: false
    t.string "donator_name"
    t.string "message"
    t.string "state", default: "pending", null: false
    t.string "paypal_order_id"
    t.string "stripe_payment_intent_id"
    t.bigint "donator_id", null: false
    t.bigint "donated_by_id"
    t.bigint "curated_streamer_id"
    t.bigint "fundraiser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curated_streamer_id"], name: "index_munificent_donations_on_curated_streamer_id"
    t.index ["donated_by_id"], name: "index_munificent_donations_on_donated_by_id"
    t.index ["donator_id"], name: "index_munificent_donations_on_donator_id"
    t.index ["fundraiser_id"], name: "index_munificent_donations_on_fundraiser_id"
    t.index ["stripe_payment_intent_id"], name: "index_munificent_donations_on_stripe_payment_intent_id", unique: true
    t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"
  end

  create_table "munificent_donator_bundle_tiers", force: :cascade do |t|
    t.bigint "donator_bundle_id", null: false
    t.bigint "bundle_tier_id", null: false
    t.boolean "unlocked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_tier_id"], name: "donator_bundle_tier_bundle_tier_id_index"
    t.index ["donator_bundle_id"], name: "donator_bundle_tier_donator_bundle_id_index"
  end

  create_table "munificent_donator_bundles", force: :cascade do |t|
    t.bigint "donator_id", null: false
    t.bigint "bundle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_id"], name: "index_munificent_donator_bundles_on_bundle_id"
    t.index ["donator_id"], name: "index_munificent_donator_bundles_on_donator_id"
  end

  create_table "munificent_donators", force: :cascade do |t|
    t.string "chosen_name"
    t.string "name"
    t.string "stripe_customer_id"
    t.string "twitch_id"
    t.string "email_address"
    t.string "unconfirmed_email_address"
    t.string "crypted_password"
    t.string "password_salt"
    t.string "persistence_token"
    t.string "single_access_token"
    t.string "perishable_token"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.datetime "last_request_at"
    t.integer "failed_login_count", default: 0, null: false
    t.integer "login_count", default: 0, null: false
    t.string "current_login_ip"
    t.string "last_login_ip"
    t.boolean "active", default: false
    t.boolean "approved", default: false
    t.boolean "confirmed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_munificent_donators_on_email_address", unique: true, where: "(confirmed = false)"
    t.index ["perishable_token"], name: "index_munificent_donators_on_perishable_token", unique: true
    t.index ["persistence_token"], name: "index_munificent_donators_on_persistence_token", unique: true
    t.index ["single_access_token"], name: "index_munificent_donators_on_single_access_token", unique: true
    t.index ["stripe_customer_id"], name: "index_munificent_donators_on_stripe_customer_id", unique: true
    t.index ["twitch_id"], name: "index_munificent_donators_on_twitch_id", unique: true
  end

  create_table "munificent_fundraisers", force: :cascade do |t|
    t.datetime "ends_at"
    t.datetime "starts_at"
    t.string "main_currency", default: "GBP", null: false
    t.string "name", null: false
    t.string "overpayment_mode", default: "pro_bono", null: false
    t.string "short_url"
    t.string "state", default: "inactive", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "munificent_games", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "munificent_keys", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "donator_bundle_tier_id"
    t.bigint "fundraiser_id"
    t.text "code_ciphertext"
    t.text "encrypted_kms_key"
    t.string "code_bidx"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_bidx"], name: "index_munificent_keys_on_code_bidx", unique: true
    t.index ["donator_bundle_tier_id", "game_id"], name: "donator_bundle_tier_game_idx", unique: true
    t.index ["donator_bundle_tier_id"], name: "index_munificent_keys_on_donator_bundle_tier_id"
    t.index ["fundraiser_id"], name: "index_munificent_keys_on_fundraiser_id"
    t.index ["game_id"], name: "index_munificent_keys_on_game_id"
  end

  create_table "munificent_payments", force: :cascade do |t|
    t.integer "amount_decimals", default: 0, null: false
    t.string "amount_currency", default: "GBP", null: false
    t.bigint "donation_id"
    t.string "stripe_payment_intent_id"
    t.string "paypal_order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["donation_id"], name: "index_munificent_payments_on_donation_id"
    t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"
  end

  add_foreign_key "munificent_bundle_tier_games", "munificent_bundle_tiers", column: "bundle_tier_id"
  add_foreign_key "munificent_bundle_tier_games", "munificent_games", column: "game_id"
  add_foreign_key "munificent_bundle_tiers", "munificent_bundles", column: "bundle_id"
  add_foreign_key "munificent_bundles", "munificent_fundraisers", column: "fundraiser_id"
  add_foreign_key "munificent_charity_fundraisers", "munificent_charities", column: "charity_id"
  add_foreign_key "munificent_charity_fundraisers", "munificent_fundraisers", column: "fundraiser_id"
  add_foreign_key "munificent_charity_splits", "munificent_charities", column: "charity_id"
  add_foreign_key "munificent_charity_splits", "munificent_donations", column: "donation_id"
  add_foreign_key "munificent_curated_streamer_administrators", "munificent_curated_streamers", column: "curated_streamer_id"
  add_foreign_key "munificent_curated_streamer_administrators", "munificent_donators", column: "donator_id"
  add_foreign_key "munificent_donations", "munificent_curated_streamers", column: "curated_streamer_id"
  add_foreign_key "munificent_donations", "munificent_donators", column: "donated_by_id"
  add_foreign_key "munificent_donations", "munificent_donators", column: "donator_id"
  add_foreign_key "munificent_donations", "munificent_fundraisers", column: "fundraiser_id"
  add_foreign_key "munificent_donator_bundle_tiers", "munificent_bundle_tiers", column: "bundle_tier_id"
  add_foreign_key "munificent_donator_bundle_tiers", "munificent_donator_bundles", column: "donator_bundle_id"
  add_foreign_key "munificent_donator_bundles", "munificent_bundles", column: "bundle_id"
  add_foreign_key "munificent_donator_bundles", "munificent_donators", column: "donator_id"
  add_foreign_key "munificent_keys", "munificent_donator_bundle_tiers", column: "donator_bundle_tier_id"
  add_foreign_key "munificent_keys", "munificent_fundraisers", column: "fundraiser_id"
  add_foreign_key "munificent_keys", "munificent_games", column: "game_id"
  add_foreign_key "munificent_payments", "munificent_donations", column: "donation_id"
end
