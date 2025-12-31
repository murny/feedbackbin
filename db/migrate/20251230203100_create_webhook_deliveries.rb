class CreateWebhookDeliveries < ActiveRecord::Migration[8.2]
  def change
    create_table :webhook_deliveries do |t|
      t.bigint :webhook_id, null: false
      t.bigint :event_id, null: false
      t.string :state, null: false, default: "pending"  # pending, in_progress, completed, errored
      t.json :request, default: {}   # Request headers, payload
      t.json :response, default: {}  # Response code, body, error
      t.timestamps
    end

    add_index :webhook_deliveries, :webhook_id
    add_index :webhook_deliveries, :event_id
    add_index :webhook_deliveries, :state
    add_index :webhook_deliveries, [:webhook_id, :state]
    add_index :webhook_deliveries, [:webhook_id, :created_at]

    add_foreign_key :webhook_deliveries, :webhooks
    add_foreign_key :webhook_deliveries, :events
  end
end
