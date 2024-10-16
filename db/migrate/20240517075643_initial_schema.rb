# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table "account_invitations", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.bigint "invited_by_id"
      t.string "token", null: false
      t.string "name", null: false
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["account_id", "email"], name: "index_account_invitations_on_account_id_and_email", unique: true
      t.index ["invited_by_id"], name: "index_account_invitations_on_invited_by_id"
      t.index ["token"], name: "index_account_invitations_on_token", unique: true
    end

    create_table "account_users", force: :cascade do |t|
      t.bigint "account_id", null: false
      t.bigint "user_id", null: false
      t.integer "role", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["account_id", "user_id"], name: "index_account_users_on_account_id_and_user_id", unique: true
    end

    create_table "accounts", force: :cascade do |t|
      t.string "name", null: false
      t.bigint "owner_id", null: false
      t.string "domain"
      t.string "subdomain"
      t.integer "account_users_count", default: 0
      t.string "billing_email"
      t.text "extra_billing_info"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["owner_id"], name: "index_accounts_on_owner_id"
    end

    create_table "action_text_rich_texts", force: :cascade do |t|
      t.string "name", null: false
      t.text "body"
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
    end

    create_table "active_storage_attachments", force: :cascade do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
      t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table "active_storage_blobs", force: :cascade do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.string "service_name", null: false
      t.bigint "byte_size", null: false
      t.string "checksum"
      t.datetime "created_at", null: false
      t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table "active_storage_variant_records", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table "addresses", force: :cascade do |t|
      t.string "addressable_type", null: false
      t.bigint "addressable_id", null: false
      t.integer "address_type"
      t.string "line1"
      t.string "line2"
      t.string "city"
      t.string "state"
      t.string "country"
      t.string "postal_code"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
    end

    create_table "boards", force: :cascade do |t|
      t.string "name", null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "changelogs", force: :cascade do |t|
      t.string "title", null: false
      t.string "kind", null: false
      t.datetime "published_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "comments", force: :cascade do |t|
      t.bigint "creator_id", null: false
      t.string "commentable_type", null: false
      t.bigint "commentable_id", null: false
      t.bigint "parent_id"
      t.integer "likes_count", default: 0
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
      t.index ["creator_id"], name: "index_comments_on_creator_id"
    end

    create_table "likes", force: :cascade do |t|
      t.bigint "voter_id", null: false
      t.string "likeable_type", null: false
      t.bigint "likeable_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["likeable_type", "likeable_id"], name: "index_likes_on_likeable"
      t.index ["voter_id"], name: "index_likes_on_voter_id"
    end

    create_table "pay_charges", force: :cascade do |t|
      t.bigint "customer_id", null: false
      t.bigint "subscription_id"
      t.string "processor_id", null: false
      t.integer "amount", null: false
      t.string "currency"
      t.integer "application_fee_amount"
      t.integer "amount_refunded"
      t.json "metadata"
      t.json "data"
      t.string "stripe_account"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "type"
      t.index ["customer_id", "processor_id"], name: "index_pay_charges_on_customer_id_and_processor_id", unique: true
      t.index ["subscription_id"], name: "index_pay_charges_on_subscription_id"
    end

    create_table "pay_customers", force: :cascade do |t|
      t.string "owner_type"
      t.bigint "owner_id"
      t.string "processor", null: false
      t.string "processor_id"
      t.boolean "default", default: false, null: false
      t.json "data"
      t.string "stripe_account"
      t.datetime "deleted_at", precision: nil
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "type"
      t.index ["owner_type", "owner_id", "deleted_at"], name: "pay_customer_owner_index", unique: true
      t.index ["processor", "processor_id"], name: "index_pay_customers_on_processor_and_processor_id", unique: true
    end

    create_table "pay_merchants", force: :cascade do |t|
      t.string "owner_type"
      t.bigint "owner_id"
      t.string "processor", null: false
      t.string "processor_id"
      t.boolean "default", default: false, null: false
      t.json "data"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "type"
      t.index ["owner_type", "owner_id", "processor"], name: "index_pay_merchants_on_owner_type_and_owner_id_and_processor"
    end

    create_table "pay_payment_methods", force: :cascade do |t|
      t.bigint "customer_id", null: false
      t.string "processor_id", null: false
      t.boolean "default", default: false, null: false
      t.string "payment_method_type"
      t.json "data"
      t.string "stripe_account"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "type"
      t.index ["customer_id", "processor_id"], name: "index_pay_payment_methods_on_customer_id_and_processor_id", unique: true
    end

    create_table "pay_subscriptions", force: :cascade do |t|
      t.bigint "customer_id", null: false
      t.string "name", null: false
      t.string "processor_id", null: false
      t.string "processor_plan", null: false
      t.integer "quantity", default: 1, null: false
      t.string "status", null: false
      t.datetime "current_period_start", precision: nil
      t.datetime "current_period_end", precision: nil
      t.datetime "trial_ends_at", precision: nil
      t.datetime "ends_at", precision: nil
      t.boolean "metered", default: false, null: false
      t.string "pause_behavior"
      t.datetime "pause_starts_at", precision: nil
      t.datetime "pause_resumes_at", precision: nil
      t.decimal "application_fee_percent", precision: 8, scale: 2
      t.json "metadata"
      t.json "data"
      t.string "stripe_account"
      t.string "payment_method_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "type"
      t.index ["customer_id", "processor_id"], name: "index_pay_subscriptions_on_customer_id_and_processor_id", unique: true
      t.index ["metered"], name: "index_pay_subscriptions_on_metered"
      t.index ["pause_starts_at"], name: "index_pay_subscriptions_on_pause_starts_at"
    end

    create_table "pay_webhooks", force: :cascade do |t|
      t.string "processor"
      t.string "event_type"
      t.json "event"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "plans", force: :cascade do |t|
      t.string "name", null: false
      t.integer "amount", default: 0, null: false
      t.string "interval", null: false
      t.json "details", default: {}, null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.integer "trial_period_days", default: 0
      t.boolean "hidden", default: false, null: false
      t.string "currency"
      t.integer "interval_count", default: 1
      t.string "description"
      t.string "unit_label"
      t.boolean "charge_per_unit", default: false, null: false
      t.string "stripe_id"
      t.string "braintree_id"
      t.string "paddle_billing_id"
      t.string "paddle_classic_id"
      t.string "lemon_squeezy_id"
      t.string "fake_processor_id"
      t.string "contact_url"
    end

    create_table "posts", force: :cascade do |t|
      t.string "title", null: false
      t.bigint "author_id", null: false
      t.integer "comments_count", default: 0, null: false
      t.integer "likes_count", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "board_id", null: false
      t.integer "status_id"
      t.index ["author_id"], name: "index_posts_on_author_id"
      t.index ["board_id"], name: "index_posts_on_board_id"
      t.index ["status_id"], name: "index_posts_on_status_id"
    end

    create_table "sessions", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.string "ip_address"
      t.string "user_agent"
      t.datetime "last_active_at", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id"], name: "index_sessions_on_user_id"
    end

    create_table "statuses", force: :cascade do |t|
      t.string "name", null: false
      t.string "color", null: false
      t.integer "position", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "users", force: :cascade do |t|
      t.string "name"
      t.string "username", null: false
      t.text "bio"
      t.string "email_address", null: false
      t.boolean "email_verified", default: false, null: false
      t.string "password_digest", null: false
      t.boolean "active", default: true, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "changelogs_read_at"
      t.index ["email_address"], name: "index_users_on_email_address", unique: true
      t.index ["username"], name: "index_users_on_username", unique: true
    end

    add_foreign_key "account_invitations", "accounts"
    add_foreign_key "account_invitations", "users", column: "invited_by_id"
    add_foreign_key "account_users", "accounts"
    add_foreign_key "account_users", "users"
    add_foreign_key "accounts", "users", column: "owner_id"
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "comments", "users", column: "creator_id"
    add_foreign_key "likes", "users", column: "voter_id"
    add_foreign_key "pay_charges", "pay_customers", column: "customer_id"
    add_foreign_key "pay_charges", "pay_subscriptions", column: "subscription_id"
    add_foreign_key "pay_payment_methods", "pay_customers", column: "customer_id"
    add_foreign_key "pay_subscriptions", "pay_customers", column: "customer_id"
    add_foreign_key "posts", "boards"
    add_foreign_key "posts", "statuses"
    add_foreign_key "posts", "users", column: "author_id"
    add_foreign_key "sessions", "users"
  end
end
