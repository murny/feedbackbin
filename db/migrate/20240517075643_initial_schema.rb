# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table "sessions", force: :cascade do |t|
      t.integer "user_id", null: false
      t.string "token", null: false
      t.string "ip_address"
      t.string "user_agent"
      t.datetime "last_active_at", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["token"], name: "index_sessions_on_token", unique: true
      t.index ["user_id"], name: "index_sessions_on_user_id"
    end

    create_table "users", force: :cascade do |t|
      t.string "name", null: false
      t.string "email_address", null: false
      t.string "password_digest", null: false
      t.integer "role", null: false
      t.boolean "active", default: true, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["email_address"], name: "index_users_on_email_address", unique: true
      t.index ["name"], name: "index_users_on_name", unique: true
    end

    add_foreign_key "sessions", "users"
  end
end
