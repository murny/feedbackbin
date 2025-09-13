# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
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
      t.string "name", null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "name" ], name: "index_categories_on_name", unique: true
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
      t.bigint "parent_id"
      t.bigint "post_id", null: false
      t.integer "likes_count", default: 0
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "creator_id" ], name: "index_comments_on_creator_id"
      t.index [ "parent_id" ], name: "index_comments_on_parent_id"
      t.index [ "post_id" ], name: "index_comments_on_post_id"
    end

    create_table "likes", force: :cascade do |t|
      t.bigint "voter_id", null: false
      t.string "likeable_type", null: false
      t.bigint "likeable_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "likeable_type", "likeable_id", "voter_id" ], name: "index_likes_on_likeable_type_and_likeable_id_and_voter_id", unique: true
      t.index [ "likeable_type", "likeable_id" ], name: "index_likes_on_likeable"
      t.index [ "voter_id" ], name: "index_likes_on_voter_id"
    end

    create_table "post_statuses", force: :cascade do |t|
      t.string "name", null: false
      t.string "color", null: false
      t.integer "position", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "posts", force: :cascade do |t|
      t.bigint "author_id", null: false
      t.integer "category_id", null: false
      t.integer "comments_count", default: 0, null: false
      t.datetime "created_at", null: false
      t.integer "likes_count", default: 0, null: false
      t.boolean "pinned", default: false, null: false
      t.integer "post_status_id"
      t.string "title", null: false
      t.datetime "updated_at", null: false
      t.index [ "author_id" ], name: "index_posts_on_author_id"
      t.index [ "category_id" ], name: "index_posts_on_category_id"
      t.index [ "pinned" ], name: "index_posts_on_pinned"
      t.index [ "post_status_id" ], name: "index_posts_on_post_status_id"
    end

    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "comments", "comments", column: "parent_id"
    add_foreign_key "comments", "posts"
    add_foreign_key "posts", "categories"
    add_foreign_key "posts", "post_statuses"
  end
end
