# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table "organization_invitations", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.bigint "invited_by_id"
      t.string "token", null: false
      t.string "name", null: false
      t.string "email", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id", "email" ], name: "index_organization_invitations_on_organization_id_and_email", unique: true
      t.index [ "invited_by_id" ], name: "index_organization_invitations_on_invited_by_id"
      t.index [ "token" ], name: "index_organization_invitations_on_token", unique: true
    end

    create_table "memberships", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.bigint "user_id", null: false
      t.integer "role", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id", "user_id" ], name: "index_memberships_on_organization_id_and_user_id", unique: true
    end

    create_table "organizations", force: :cascade do |t|
      t.string "name", null: false
      t.bigint "owner_id", null: false
      t.string "domain"
      t.string "subdomain"
      t.integer "memberships_count", default: 0, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "owner_id" ], name: "index_organizations_on_owner_id"
    end

    create_table "action_text_rich_texts", force: :cascade do |t|
      t.string "name", null: false
      t.text "body"
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "record_type", "record_id", "name" ], name: "index_action_text_rich_texts_uniqueness", unique: true
    end

    create_table "active_storage_attachments", force: :cascade do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
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
      t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table "active_storage_variant_records", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table "categories", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.string "name", null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id" ], name: "index_categories_on_organization_id"
    end

    create_table "changelogs", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.string "title", null: false
      t.string "kind", null: false
      t.datetime "published_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id" ], name: "index_changelogs_on_organization_id"
    end

    create_table "comments", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.bigint "creator_id", null: false
      t.bigint "parent_id"
      t.bigint "post_id", null: false
      t.integer "likes_count", default: 0
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id" ], name: "index_comments_on_organization_id"
      t.index [ "creator_id" ], name: "index_comments_on_creator_id"
      t.index [ "parent_id" ], name: "index_comments_on_parent_id"
      t.index [ "post_id" ], name: "index_comments_on_post_id"
    end

    create_table "likes", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.bigint "voter_id", null: false
      t.string "likeable_type", null: false
      t.bigint "likeable_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id" ], name: "index_likes_on_organization_id"
      t.index [ "likeable_type", "likeable_id", "voter_id" ], name: "index_likes_on_likeable_type_and_likeable_id_and_voter_id", unique: true
      t.index [ "likeable_type", "likeable_id" ], name: "index_likes_on_likeable"
      t.index [ "voter_id" ], name: "index_likes_on_voter_id"
    end

    create_table "post_statuses", force: :cascade do |t|
      t.bigint "organization_id", null: false
      t.string "name", null: false
      t.string "color", null: false
      t.integer "position", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "organization_id" ], name: "index_post_statuses_on_organization_id"
    end

    create_table "posts", force: :cascade do |t|
      t.bigint "author_id", null: false
      t.integer "category_id", null: false
      t.integer "comments_count", default: 0, null: false
      t.datetime "created_at", null: false
      t.integer "likes_count", default: 0, null: false
      t.bigint "organization_id", null: false
      t.boolean "pinned", default: false, null: false
      t.integer "post_status_id"
      t.string "title", null: false
      t.datetime "updated_at", null: false
      t.index [ "author_id" ], name: "index_posts_on_author_id"
      t.index [ "category_id" ], name: "index_posts_on_category_id"
      t.index [ "organization_id" ], name: "index_posts_on_organization_id"
      t.index [ "pinned" ], name: "index_posts_on_pinned"
      t.index [ "post_status_id" ], name: "index_posts_on_post_status_id"
    end

    create_table "sessions", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.string "ip_address"
      t.string "user_agent"
      t.datetime "last_active_at", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "user_id" ], name: "index_sessions_on_user_id"
    end

    create_table "user_connected_accounts", force: :cascade do |t|
      t.integer "user_id", null: false
      t.string "provider_name", null: false
      t.string "provider_uid", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "provider_name", "provider_uid" ], name: "index_user_connected_accounts_on_provider_name_and_provider_uid", unique: true
      t.index [ "provider_name", "user_id" ], name: "index_user_connected_accounts_on_provider_name_and_user_id", unique: true
      t.index [ "user_id" ], name: "index_user_connected_accounts_on_user_id"
    end

    create_table "users", force: :cascade do |t|
      t.string "name"
      t.string "username", null: false
      t.text "bio"
      t.string "email_address", null: false
      t.boolean "email_verified", default: false, null: false
      t.string "password_digest", null: false
      t.boolean "active", default: true, null: false
      t.boolean "site_admin", default: false, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "changelogs_read_at"
      t.string "time_zone"
      t.string "preferred_language"
      t.integer "theme", default: 0, null: false
      t.index [ "email_address" ], name: "index_users_on_email_address", unique: true
      t.index [ "username" ], name: "index_users_on_username", unique: true
    end

    add_foreign_key "organization_invitations", "organizations"
    add_foreign_key "organization_invitations", "users", column: "invited_by_id"
    add_foreign_key "memberships", "organizations"
    add_foreign_key "memberships", "users"
    add_foreign_key "organizations", "users", column: "owner_id"
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "categories", "organizations"
    add_foreign_key "changelogs", "organizations"
    add_foreign_key "comments", "organizations"
    add_foreign_key "comments", "comments", column: "parent_id"
    add_foreign_key "comments", "posts"
    add_foreign_key "comments", "users", column: "creator_id"
    add_foreign_key "likes", "organizations"
    add_foreign_key "likes", "users", column: "voter_id"
    add_foreign_key "post_statuses", "organizations"
    add_foreign_key "posts", "organizations"
    add_foreign_key "posts", "categories"
    add_foreign_key "posts", "post_statuses"
    add_foreign_key "posts", "users", column: "author_id"
    add_foreign_key "sessions", "users"
    add_foreign_key "user_connected_accounts", "users"
  end
end
