# frozen_string_literal: true

class InitialSchema < ActiveRecord::Migration[8.0]
  def change
    create_table "organizations", force: :cascade do |t|
      t.datetime "created_at", null: false
      t.integer "memberships_count", default: 0, null: false
      t.string "name", null: false
      t.bigint "owner_id", null: false
      t.string "subdomain"
      t.datetime "updated_at", null: false
      t.index [ "owner_id" ], name: "index_organizations_on_owner_id"
    end
  end
end
