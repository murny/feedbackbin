# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table "accounts", force: :cascade do |t|
      t.string "name", null: false
      t.string "join_code", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
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

    create_table "connected_identities", force: :cascade do |t|
      t.bigint "owner_id"
      t.string "provider"
      t.string "uid"
      t.string "refresh_token"
      t.datetime "expires_at", precision: nil
      t.text "auth"
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.string "access_token"
      t.string "access_token_secret"
      t.string "owner_type"
      t.index ["owner_id", "owner_type"], name: "index_connected_identities_on_owner_id_and_owner_type"
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
      t.integer "role", default: 0, null: false
      t.boolean "active", default: true, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "changelogs_read_at"
      t.index ["email_address"], name: "index_users_on_email_address", unique: true
      t.index ["username"], name: "index_users_on_username", unique: true
    end

    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "comments", "users", column: "creator_id"
    add_foreign_key "likes", "users", column: "voter_id"
    add_foreign_key "posts", "boards"
    add_foreign_key "posts", "statuses"
    add_foreign_key "posts", "users", column: "author_id"
    add_foreign_key "sessions", "users"
  end
end
