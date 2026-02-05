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

ActiveRecord::Schema[8.2].define(version: 2026_02_02_235808) do
  create_table "account_external_id_sequences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "value", default: 0, null: false
    t.index ["value"], name: "index_account_external_id_sequences_on_value", unique: true
  end

  create_table "accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "external_account_id", null: false
    t.string "logo_link"
    t.string "name", null: false
    t.boolean "show_company_name", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["external_account_id"], name: "index_accounts_on_external_account_id", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_action_text_rich_texts_on_account_id"
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["account_id"], name: "index_active_storage_attachments_on_account_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["account_id"], name: "index_active_storage_blobs_on_account_id"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["account_id"], name: "index_active_storage_variant_records_on_account_id"
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "boards", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "name"], name: "index_boards_on_account_id_and_name", unique: true
    t.index ["account_id"], name: "index_boards_on_account_id"
    t.index ["creator_id"], name: "index_boards_on_creator_id"
  end

  create_table "changelogs", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.datetime "published_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_changelogs_on_account_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.bigint "idea_id", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.integer "votes_count", default: 0
    t.index ["account_id"], name: "index_comments_on_account_id"
    t.index ["creator_id"], name: "index_comments_on_creator_id"
    t.index ["idea_id"], name: "index_comments_on_idea_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "action", null: false
    t.bigint "board_id", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.bigint "eventable_id", null: false
    t.string "eventable_type", null: false
    t.json "particulars", default: {}
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_events_on_account_id"
    t.index ["action"], name: "index_events_on_action"
    t.index ["board_id", "action", "created_at"], name: "index_events_on_board_id_and_action_and_created_at"
    t.index ["board_id"], name: "index_events_on_board_id"
    t.index ["creator_id"], name: "index_events_on_creator_id"
    t.index ["eventable_type", "eventable_id"], name: "index_events_on_eventable_type_and_eventable_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.integer "board_id", null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.boolean "pinned", default: false, null: false
    t.integer "status_id"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["account_id"], name: "index_ideas_on_account_id"
    t.index ["board_id"], name: "index_ideas_on_board_id"
    t.index ["creator_id"], name: "index_ideas_on_creator_id"
    t.index ["pinned"], name: "index_ideas_on_pinned"
    t.index ["status_id"], name: "index_ideas_on_status_id"
  end

  create_table "identities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.datetime "email_verified_at"
    t.string "password_digest"
    t.boolean "staff", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_identities_on_email_address", unique: true
  end

  create_table "identity_connected_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "identity_id", null: false
    t.string "provider_name", null: false
    t.string "provider_uid", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_identity_connected_accounts_on_identity_id"
    t.index ["provider_name", "identity_id"], name: "idx_id_connected_accounts_on_provider_name_and_identity_id", unique: true
    t.index ["provider_name", "provider_uid"], name: "idx_id_connected_accounts_on_provider_name_and_provider_uid", unique: true
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "invited_by_id", null: false
    t.string "name", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "email"], name: "index_invitations_on_account_id_and_email", unique: true
    t.index ["account_id"], name: "index_invitations_on_account_id"
    t.index ["invited_by_id"], name: "index_invitations_on_invited_by_id"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "magic_links", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.integer "identity_id", null: false
    t.integer "purpose", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_magic_links_on_code", unique: true
    t.index ["expires_at"], name: "index_magic_links_on_expires_at"
    t.index ["identity_id"], name: "index_magic_links_on_identity_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "mentionee_id", null: false
    t.integer "mentioner_id", null: false
    t.integer "source_id", null: false
    t.string "source_type", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_mentions_on_account_id"
    t.index ["mentionee_id"], name: "index_mentions_on_mentionee_id"
    t.index ["mentioner_id"], name: "index_mentions_on_mentioner_id"
    t.index ["source_type", "source_id", "mentionee_id"], name: "index_mentions_on_source_type_and_source_id_and_mentionee_id", unique: true
    t.index ["source_type", "source_id"], name: "index_mentions_on_source"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id", null: false
    t.datetime "read_at"
    t.bigint "source_id", null: false
    t.string "source_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["account_id"], name: "index_notifications_on_account_id"
    t.index ["creator_id"], name: "index_notifications_on_creator_id"
    t.index ["source_type", "source_id"], name: "index_notifications_on_source_type_and_source_id"
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "content", limit: 16, null: false
    t.datetime "created_at", null: false
    t.integer "reactable_id", null: false
    t.string "reactable_type", null: false
    t.integer "reacter_id", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_reactions_on_account_id"
    t.index ["reactable_type", "reactable_id"], name: "index_reactions_on_reactable"
    t.index ["reacter_id", "reactable_type", "reactable_id", "content"], name: "index_reactions_uniqueness", unique: true
    t.index ["reacter_id"], name: "index_reactions_on_reacter_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "identity_id", null: false
    t.string "ip_address"
    t.datetime "last_active_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["identity_id"], name: "index_sessions_on_identity_id"
  end

  create_table "statuses", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", null: false
    t.boolean "show_on_idea", default: true, null: false
    t.boolean "show_on_roadmap", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_statuses_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.text "bio"
    t.datetime "changelogs_read_at"
    t.datetime "created_at", null: false
    t.bigint "identity_id"
    t.string "name", limit: 255, null: false
    t.string "preferred_language"
    t.string "role", default: "member", null: false
    t.integer "theme", default: 0, null: false
    t.string "time_zone"
    t.datetime "updated_at", null: false
    t.index ["account_id", "identity_id"], name: "index_users_on_account_id_and_identity_id", unique: true
    t.index ["account_id", "role"], name: "index_users_on_account_id_and_role"
    t.index ["identity_id"], name: "index_users_on_identity_id"
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "voteable_id", null: false
    t.string "voteable_type", null: false
    t.bigint "voter_id", null: false
    t.index ["account_id"], name: "index_votes_on_account_id"
    t.index ["voteable_type", "voteable_id", "voter_id"], name: "index_votes_on_voteable_type_and_voteable_id_and_voter_id", unique: true
    t.index ["voter_id"], name: "index_votes_on_voter_id"
  end

  create_table "watches", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.integer "idea_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.boolean "watching", default: true, null: false
    t.index ["account_id"], name: "index_watches_on_account_id"
    t.index ["idea_id"], name: "index_watches_on_idea_id"
    t.index ["user_id", "idea_id"], name: "index_watches_on_user_id_and_idea_id", unique: true
    t.index ["user_id"], name: "index_watches_on_user_id"
  end

  create_table "webhook_delinquency_trackers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "consecutive_failures_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "first_failure_at"
    t.datetime "updated_at", null: false
    t.integer "webhook_id", null: false
    t.index ["account_id"], name: "index_webhook_delinquency_trackers_on_account_id"
    t.index ["webhook_id"], name: "index_webhook_delinquency_trackers_on_webhook_id"
  end

  create_table "webhook_deliveries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.json "request", default: {}
    t.json "response", default: {}
    t.string "state", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "webhook_id", null: false
    t.index ["account_id"], name: "index_webhook_deliveries_on_account_id"
    t.index ["event_id"], name: "index_webhook_deliveries_on_event_id"
    t.index ["state"], name: "index_webhook_deliveries_on_state"
    t.index ["webhook_id", "created_at"], name: "index_webhook_deliveries_on_webhook_id_and_created_at"
    t.index ["webhook_id", "state"], name: "index_webhook_deliveries_on_webhook_id_and_state"
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhooks", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.boolean "active", default: true, null: false
    t.bigint "board_id"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "signing_secret", null: false
    t.json "subscribed_actions", default: []
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["account_id", "active"], name: "index_webhooks_on_account_id_and_active"
    t.index ["account_id"], name: "index_webhooks_on_account_id"
    t.index ["active"], name: "index_webhooks_on_active"
    t.index ["board_id"], name: "index_webhooks_on_board_id"
  end

  add_foreign_key "reactions", "accounts"
  add_foreign_key "reactions", "users", column: "reacter_id"
end
