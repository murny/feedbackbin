# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.2]
  def change
    create_table "accounts", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.integer "default_status_id", null: false
      t.string "logo_link"
      t.string "name", null: false
      t.boolean "show_company_name", default: true, null: false
      t.datetime "updated_at", null: false
      t.index [ "default_status_id" ], name: "index_accounts_on_default_status_id"
    end

    create_table "action_text_rich_texts", force: :cascade do |t|
      t.text "body"
      t.datetime "created_at", null: false
      t.string "name", null: false
      t.bigint "record_id", null: false
      t.string "record_type", null: false
      t.datetime "updated_at", null: false
      t.index [ "record_type", "record_id", "name" ], name: "index_action_text_rich_texts_uniqueness", unique: true
    end

    create_table "active_storage_attachments", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.string "name", null: false
      t.bigint "record_id", null: false
      t.string "record_type", null: false
      t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table "active_storage_blobs", force: :cascade do |t|
      t.bigint "byte_size", null: false
      t.string "checksum"
      t.string "content_type"
      t.datetime "created_at", null: false
      t.string "filename", null: false
      t.string "key", null: false
      t.text "metadata"
      t.string "service_name", null: false
      t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table "active_storage_variant_records", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table "boards", force: :cascade do |t|
      t.string "color", null: false
      t.datetime "created_at", null: false
      t.text "description"
      t.string "name", null: false
      t.datetime "updated_at", null: false
      t.index [ "name" ], name: "index_boards_on_name", unique: true
    end

    create_table "changelogs", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.string "kind", null: false
      t.datetime "published_at"
      t.string "title", null: false
      t.datetime "updated_at", null: false
    end

    create_table "comments", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.bigint "creator_id", null: false
      t.bigint "idea_id", null: false
      t.bigint "parent_id"
      t.datetime "updated_at", null: false
      t.integer "votes_count", default: 0
      t.index [ "creator_id" ], name: "index_comments_on_creator_id"
      t.index [ "idea_id" ], name: "index_comments_on_idea_id"
      t.index [ "parent_id" ], name: "index_comments_on_parent_id"
    end

    create_table "ideas", force: :cascade do |t|
      t.bigint "author_id", null: false
      t.integer "board_id", null: false
      t.integer "comments_count", default: 0, null: false
      t.datetime "created_at", null: false
      t.boolean "pinned", default: false, null: false
      t.integer "status_id", null: false
      t.string "title", null: false
      t.datetime "updated_at", null: false
      t.integer "votes_count", default: 0, null: false
      t.index [ "author_id" ], name: "index_ideas_on_author_id"
      t.index [ "board_id" ], name: "index_ideas_on_board_id"
      t.index [ "pinned" ], name: "index_ideas_on_pinned"
      t.index [ "status_id" ], name: "index_ideas_on_status_id"
    end

    create_table "invitations", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.string "email", null: false
      t.bigint "invited_by_id", null: false
      t.string "name", null: false
      t.string "token", null: false
      t.datetime "updated_at", null: false
      t.index [ "email" ], name: "index_invitations_on_email", unique: true
      t.index [ "invited_by_id" ], name: "index_invitations_on_invited_by_id"
      t.index [ "token" ], name: "index_invitations_on_token", unique: true
    end

    create_table "sessions", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.string "ip_address"
      t.datetime "last_active_at", null: false
      t.datetime "updated_at", null: false
      t.string "user_agent"
      t.bigint "user_id", null: false
      t.index [ "user_id" ], name: "index_sessions_on_user_id"
    end

    create_table "statuses", force: :cascade do |t|
      t.string "color", null: false
      t.datetime "created_at", null: false
      t.string "name", null: false
      t.integer "position", null: false
      t.boolean "show_on_idea", default: true, null: false
      t.boolean "show_on_roadmap", default: false, null: false
      t.datetime "updated_at", null: false
    end

    create_table "user_connected_accounts", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.string "provider_name", null: false
      t.string "provider_uid", null: false
      t.datetime "updated_at", null: false
      t.integer "user_id", null: false
      t.index [ "provider_name", "provider_uid" ], name: "index_user_connected_accounts_on_provider_name_and_provider_uid", unique: true
      t.index [ "provider_name", "user_id" ], name: "index_user_connected_accounts_on_provider_name_and_user_id", unique: true
      t.index [ "user_id" ], name: "index_user_connected_accounts_on_user_id"
    end

    create_table "users", force: :cascade do |t|
      t.boolean "active", default: true, null: false
      t.text "bio"
      t.datetime "changelogs_read_at"
      t.datetime "created_at", null: false
      t.string "email_address", null: false
      t.boolean "email_verified", default: false, null: false
      t.string "name", limit: 255, null: false
      t.string "password_digest", null: false
      t.string "preferred_language"
      t.string "role", default: "member", null: false
      t.boolean "staff", default: false, null: false
      t.integer "theme", default: 0, null: false
      t.string "time_zone"
      t.datetime "updated_at", null: false
      t.index [ "email_address" ], name: "index_users_on_email_address", unique: true
    end

    create_table "votes", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "voteable_id", null: false
      t.string "voteable_type", null: false
      t.bigint "voter_id", null: false
      t.index [ "voteable_type", "voteable_id", "voter_id" ], name: "index_votes_on_voteable_type_and_voteable_id_and_voter_id", unique: true
      t.index [ "voteable_type", "voteable_id" ], name: "index_likes_on_likeable"
      t.index [ "voter_id" ], name: "index_votes_on_voter_id"
    end

    add_foreign_key "accounts", "statuses", column: "default_status_id"
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "comments", "comments", column: "parent_id"
    add_foreign_key "comments", "ideas"
    add_foreign_key "comments", "users", column: "creator_id"
    add_foreign_key "ideas", "boards"
    add_foreign_key "ideas", "statuses"
    add_foreign_key "ideas", "users", column: "author_id"
    add_foreign_key "invitations", "users", column: "invited_by_id"
    add_foreign_key "sessions", "users"
    add_foreign_key "user_connected_accounts", "users"
    add_foreign_key "votes", "users", column: "voter_id"
  end
end
