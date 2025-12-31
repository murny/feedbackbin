# Phase 3: Webhooks System

## Overview

Phase 3 builds on the events system (Phase 1) to provide webhook integrations. When events occur, HTTP POST requests are automatically sent to configured webhook endpoints, enabling real-time integration with external systems like Slack, Discord, Zapier, or custom applications.

## What We Built

### 1. Database Schema

#### Webhooks Table

**Migration:** `db/migrate/20251230203000_create_webhooks.rb`

```ruby
create_table :webhooks do |t|
  t.bigint :account_id, null: false
  t.bigint :board_id                     # Optional: scope to specific board
  t.string :name, null: false
  t.string :url, null: false             # Webhook endpoint
  t.string :signing_secret, null: false  # For HMAC-SHA256 signing
  t.json :subscribed_actions, default: []
  t.boolean :active, default: true
  t.text :description
  t.timestamps
end
```

**Key features:**
- **Account-scoped** - Each webhook belongs to an account
- **Optional board filtering** - Can limit to events from specific board
- **Action subscriptions** - Filter which event types trigger webhook
- **Active/inactive toggle** - Enable/disable without deleting
- **Auto-generated signing secret** - For payload verification

#### Webhook Deliveries Table

**Migration:** `db/migrate/20251230203100_create_webhook_deliveries.rb`

```ruby
create_table :webhook_deliveries do |t|
  t.bigint :webhook_id, null: false
  t.bigint :event_id, null: false
  t.string :state, null: false, default: "pending"
  t.json :request, default: {}   # Headers, payload, URL
  t.json :response, default: {}  # Status code, body, errors
  t.timestamps
end
```

**State machine:**
- `pending` → `in_progress` → `completed` (success)
- `pending` → `in_progress` → `errored` (failure)

**Purpose:**
- Audit trail of all webhook attempts
- Debugging failed deliveries
- Retry capabilities
- Performance monitoring

### 2. Core Models

#### Webhook Model (`app/models/webhook.rb`)

```ruby
class Webhook < ApplicationRecord
  include Webhook::Triggerable

  PERMITTED_ACTIONS = %w[
    idea_created
    idea_status_changed
    idea_board_changed
    idea_title_changed
    comment_created
  ].freeze

  has_secure_token :signing_secret  # Automatic secret generation

  belongs_to :account
  belongs_to :board, optional: true
  has_many :deliveries, class_name: "Webhook::Delivery"

  validates :name, presence: true
  validates :url, presence: true, format: URI
  validates :subscribed_actions, presence: true

  scope :active, -> { where(active: true) }

  def activate / deactivate
  def subscribed_to?(action)
end
```

**Key methods:**
- `activate` / `deactivate` - Toggle webhook status
- `subscribed_to?(action)` - Check if webhook listens to action
- `trigger(event)` - Create delivery for event

#### Webhook::Triggerable Concern (`app/models/webhook/triggerable.rb`)

Provides scopes and filtering logic:

```ruby
scope :triggered_by, ->(event) {
  where(account: event.account)
    .where("board_id IS NULL OR board_id = ?", event.board_id)
    .triggered_by_action(event.action)
}

scope :triggered_by_action, ->(action) {
  where("JSON_CONTAINS(subscribed_actions, ?)", "\"#{action}\"")
}

def trigger(event)
  deliveries.create!(event: event)
end
```

**Filtering logic:**
1. Account must match
2. Board must match (or webhook has no board filter)
3. Action must be in subscribed_actions array

#### Webhook::Delivery Model (`app/models/webhook/delivery.rb`)

Handles HTTP execution and HMAC signing:

```ruby
class Webhook::Delivery < ApplicationRecord
  enum :state, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    errored: "errored"
  }

  belongs_to :webhook
  belongs_to :event

  after_create_commit :deliver_later

  def deliver
    # 1. Build HTTP request
    # 2. Generate HMAC-SHA256 signature
    # 3. Send POST request
    # 4. Record response
    # 5. Update state
  end

  def succeeded?
    completed? && response["code"]&.between?(200, 299)
  end
end
```

**Security features:**
- **HMAC-SHA256 signing** - Payload authenticity verification
- **Timeout protection** - 5s connect, 7s read, 5s write
- **Response size limiting** - 1KB response body max
- **Automatic retries** - 3 attempts with exponential backoff

**HTTP Headers sent:**
```http
POST /webhook HTTP/1.1
Content-Type: application/json
User-Agent: FeedbackBin-Webhook/1.0
X-Webhook-Signature: sha256=abc123...
X-Webhook-Timestamp: 2025-12-30T20:30:00Z

{payload}
```

### 3. Payload Format

#### JSON Payload Structure

```json
{
  "event": {
    "id": 123,
    "action": "idea_status_changed",
    "created_at": "2025-12-30T20:30:00Z",
    "eventable_type": "Idea",
    "eventable_id": 456,
    "creator": {
      "id": 789,
      "name": "John Doe"
    },
    "board": {
      "id": 101,
      "name": "Feature Requests"
    },
    "particulars": {
      "old_status": "Open",
      "new_status": "In Progress"
    }
  }
}
```

**Key fields:**
- `action` - Event type (idea_created, comment_created, etc.)
- `eventable_type/id` - The Idea or Comment that changed
- `creator` - Who triggered the event
- `board` - Board context
- `particulars` - Event-specific metadata

#### Signature Verification

Recipients should verify the HMAC signature:

```ruby
# Ruby example
payload = request.body.read
signature = request.headers["X-Webhook-Signature"]
expected_signature = "sha256=" + OpenSSL::HMAC.hexdigest(
  "SHA256",
  webhook.signing_secret,
  payload
)

if ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
  # Signature valid - process webhook
else
  # Invalid signature - reject
end
```

```javascript
// Node.js example
const crypto = require('crypto');

const signature = req.headers['x-webhook-signature'];
const payload = JSON.stringify(req.body);
const expectedSignature = 'sha256=' + crypto
  .createHmac('sha256', signingSecret)
  .update(payload)
  .digest('hex');

if (crypto.timingSafeEqual(
  Buffer.from(signature),
  Buffer.from(expectedSignature)
)) {
  // Valid signature
}
```

### 4. Background Jobs

#### Webhook::DispatchJob (`app/jobs/webhook/dispatch_job.rb`)

Enqueued when Event is created:

```ruby
def perform(event)
  Webhook.active.triggered_by(event).find_each do |webhook|
    webhook.trigger(event)  # Creates Webhook::Delivery
  end
end
```

**Queue:** `webhooks`
**Triggered by:** `Event.after_create_commit`

#### Webhook::DeliveryJob (`app/jobs/webhook/delivery_job.rb`)

Executes the actual HTTP request:

```ruby
def perform(delivery)
  delivery.deliver  # Makes HTTP POST request
end
```

**Queue:** `webhooks`
**Retry policy:** 3 attempts with exponential backoff
**Triggered by:** `Webhook::Delivery.after_create_commit`

### 5. Event Integration

Updated `app/models/event.rb`:

```ruby
has_many :webhook_deliveries, class_name: "Webhook::Delivery"

after_create_commit :dispatch_webhooks

private
  def dispatch_webhooks
    Webhook::DispatchJob.perform_later(self)
  end
```

**Flow:**
1. Event created (e.g., idea status changed)
2. `after_create_commit` triggers `dispatch_webhooks`
3. `Webhook::DispatchJob` enqueued
4. Job finds all matching webhooks
5. Creates `Webhook::Delivery` for each
6. Each delivery auto-enqueues `Webhook::DeliveryJob`
7. Job executes HTTP POST request
8. Response/errors recorded in database

### 6. Admin Interface

#### Controller (`app/controllers/admin/settings/webhooks_controller.rb`)

Standard CRUD operations:
- `GET /admin/settings/webhooks` - List webhooks
- `GET /admin/settings/webhooks/new` - New webhook form
- `POST /admin/settings/webhooks` - Create webhook
- `GET /admin/settings/webhooks/:id/edit` - Edit form
- `PATCH /admin/settings/webhooks/:id` - Update webhook
- `DELETE /admin/settings/webhooks/:id` - Delete webhook
- `POST /admin/settings/webhooks/:id/activate` - Enable webhook
- `POST /admin/settings/webhooks/:id/deactivate` - Disable webhook

**Security:** All actions scoped to `Current.account.webhooks`

#### Routes

```ruby
namespace :admin do
  namespace :settings do
    resources :webhooks do
      member do
        post :activate
        post :deactivate
      end
    end
  end
end
```

### 7. Configuration Example

```ruby
# Creating a webhook via console
webhook = Webhook.create!(
  account: Current.account,
  name: "Slack Notifications",
  url: "https://hooks.slack.com/services/T00/B00/XX",
  subscribed_actions: [
    "idea_created",
    "idea_status_changed",
    "comment_created"
  ],
  board: Board.find_by(name: "Feature Requests"), # Optional
  description: "Sends new ideas and comments to #product channel"
)

# Webhook is automatically given a signing_secret
webhook.signing_secret
# => "abc123def456..." (use this to verify payloads)

# Test the webhook
idea = Idea.create!(title: "Test", board: board)
# => Webhook delivery created and dispatched automatically
```

## How It Works

### Complete Webhook Flow

```
1. User creates an idea
   ↓
2. Idea#after_create_commit triggers track_event(:created)
   ↓
3. Event created with action: "idea_created"
   ↓
4. Event#after_create_commit triggers dispatch_webhooks
   ↓
5. Webhook::DispatchJob.perform_later(event)
   ↓
6. Job runs: Webhook.active.triggered_by(event)
   Finds webhooks where:
   - account matches
   - board matches (or null)
   - "idea_created" in subscribed_actions
   ↓
7. For each matching webhook: webhook.trigger(event)
   Creates Webhook::Delivery record (state: pending)
   ↓
8. Webhook::Delivery#after_create_commit
   Enqueues Webhook::DeliveryJob.perform_later(delivery)
   ↓
9. Job runs: delivery.deliver
   - Builds JSON payload
   - Generates HMAC-SHA256 signature
   - Sends HTTP POST request
   - Records response
   - Updates state (completed or errored)
   ↓
10. Webhook endpoint receives:
    POST /webhook
    X-Webhook-Signature: sha256=...
    X-Webhook-Timestamp: 2025-...

    {event payload}
   ↓
11. Endpoint verifies signature and processes event
```

### Example Scenarios

#### Scenario 1: Slack Integration

```ruby
# Admin creates webhook
webhook = Webhook.create!(
  name: "Slack: New Ideas",
  url: "https://hooks.slack.com/services/...",
  subscribed_actions: ["idea_created"]
)

# User creates idea
idea = Idea.create!(title: "Add dark mode", board: features_board)

# Slack receives webhook:
POST https://hooks.slack.com/services/...
{
  "event": {
    "action": "idea_created",
    "eventable_type": "Idea",
    "creator": { "name": "Alice" },
    "board": { "name": "Features" },
    ...
  }
}

# Slack bot posts: "💡 Alice created new idea: Add dark mode"
```

#### Scenario 2: Custom Integration

```ruby
# Admin creates webhook to custom system
webhook = Webhook.create!(
  name: "Analytics Tracker",
  url: "https://analytics.example.com/webhook",
  subscribed_actions: ["idea_created", "idea_status_changed"]
)

# Events trigger webhooks
idea.update(status: in_progress_status)

# Custom system receives:
POST https://analytics.example.com/webhook
X-Webhook-Signature: sha256=abc123...

{
  "event": {
    "action": "idea_status_changed",
    "particulars": {
      "old_status": "Open",
      "new_status": "In Progress"
    }
  }
}

# Analytics system tracks: status_change event
```

#### Scenario 3: Board-Specific Webhooks

```ruby
# Webhook only for "Bug Reports" board
webhook = Webhook.create!(
  name: "Bug Alert Bot",
  url: "https://bugs.example.com/webhook",
  board: Board.find_by(name: "Bug Reports"),
  subscribed_actions: ["idea_created"]
)

# Idea in "Feature Requests" board
Idea.create!(title: "Feature X", board: features_board)
# => Webhook NOT triggered (wrong board)

# Idea in "Bug Reports" board
Idea.create!(title: "Bug fix", board: bugs_board)
# => Webhook triggered! ✓
```

## Integration with Previous Phases

| Phase | Integration Point |
|-------|------------------|
| **Phase 1 (Events)** | Webhooks dispatch on Event creation |
| **Phase 2 (Notifications)** | Both triggered by same events independently |

**Shared foundation:**
- `Event.after_create_commit` triggers both notifications AND webhooks
- `Event.description_for(user)` could be used in webhook payloads
- `Event.particulars` provides rich metadata for webhooks

## Use Cases

### 1. Chat Integrations
- **Slack** - Post new ideas to #product channel
- **Discord** - Notify community of status changes
- **Microsoft Teams** - Alert team of new comments

### 2. Project Management
- **Jira** - Auto-create tickets from ideas
- **Asana** - Sync status changes to tasks
- **Linear** - Create issues from feedback

### 3. Analytics & Monitoring
- **Mixpanel** - Track idea creation events
- **Segment** - Forward events to data warehouse
- **Custom dashboards** - Real-time metrics

### 4. Automation
- **Zapier** - Trigger multi-step workflows
- **Make** - Connect to 1000+ apps
- **Custom scripts** - Process events programmatically

### 5. Customer Communication
- **Email notifications** - Custom notification logic
- **SMS alerts** - Critical status changes
- **Push notifications** - Mobile app updates

## Security Best Practices

### For FeedbackBin Admins

1. **Protect signing secrets** - Never commit to git
2. **Use HTTPS only** - Reject http:// webhook URLs
3. **Limit subscriptions** - Only subscribe to needed events
4. **Monitor deliveries** - Check for failures regularly
5. **Rotate secrets** - Periodically regenerate

### For Webhook Receivers

1. **Verify signatures** - Always validate HMAC-SHA256
2. **Check timestamps** - Reject old payloads (replay attacks)
3. **Validate payload** - Don't trust data blindly
4. **Handle errors gracefully** - Return 2xx even for validation errors
5. **Process async** - Don't block webhook response
6. **Implement rate limiting** - Protect against floods

## Performance Considerations

- **Async processing** - All webhook calls non-blocking
- **Separate queue** - `webhooks` queue isolated from other jobs
- **Retry logic** - 3 attempts with exponential backoff
- **Timeout protection** - 7s max per request
- **Connection pooling** - Reuse HTTP connections
- **Indexed queries** - Fast webhook lookup

## Future Enhancements

### Phase 3.5: Advanced Features

- [ ] **Delivery retry UI** - Manual retry button for failed deliveries
- [ ] **Webhook testing** - Send test payloads from admin
- [ ] **Delivery logs UI** - View request/response in admin
- [ ] **Filtering by eventable** - Only ideas with certain tags
- [ ] **Custom headers** - Add auth headers to requests
- [ ] **Payload templates** - Customize JSON format
- [ ] **Rate limiting** - Limit deliveries per minute
- [ ] **Batch deliveries** - Group multiple events
- [ ] **Webhook secrets rotation** - UI for regenerating secrets

### Phase 3.6: Reliability

- [ ] **Delinquency tracking** - Auto-disable failing webhooks
- [ ] **Circuit breaker** - Stop trying after X failures
- [ ] **Dead letter queue** - Store failed deliveries
- [ ] **Exponential backoff** - Smarter retry timing
- [ ] **Health checks** - Ping webhook endpoints
- [ ] **Webhook analytics** - Success rate metrics

## Files Created/Modified

**New files:**
- `db/migrate/20251230203000_create_webhooks.rb`
- `db/migrate/20251230203100_create_webhook_deliveries.rb`
- `app/models/webhook.rb`
- `app/models/webhook/triggerable.rb`
- `app/models/webhook/delivery.rb`
- `app/jobs/webhook/dispatch_job.rb`
- `app/jobs/webhook/delivery_job.rb`
- `app/controllers/admin/settings/webhooks_controller.rb`

**Modified files:**
- `app/models/event.rb` - Added webhook dispatch
- `app/models/account.rb` - Added `has_many :webhooks`
- `config/routes.rb` - Added webhook routes
- `config/locales/en.yml` - Added webhook translations

## Testing Webhooks

```ruby
# In rails console

# Create webhook
webhook = Webhook.create!(
  account: Account.first,
  name: "Test Webhook",
  url: "https://webhook.site/unique-uuid",  # Use webhook.site for testing
  subscribed_actions: ["idea_created", "comment_created"]
)

# Get signing secret
puts webhook.signing_secret
# => Copy this to webhook.site for verification

# Trigger event
idea = Idea.create!(title: "Test", board: Board.first)

# Wait a moment for jobs
sleep 2

# Check delivery
delivery = webhook.deliveries.last
delivery.state  # => "completed"
delivery.succeeded?  # => true
delivery.response  # => {code: 200, ...}

# View in webhook.site to see:
# - Headers (including X-Webhook-Signature)
# - JSON payload
# - Verify signature matches
```

### Testing Signature Verification

```bash
# Using curl and openssl
PAYLOAD='{"event":{"id":123}}'
SECRET='your_signing_secret'
SIGNATURE=$(echo -n "$PAYLOAD" | openssl dgst -sha256 -hmac "$SECRET" -binary | base64)

curl -X POST https://your-endpoint.com/webhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Signature: sha256=$SIGNATURE" \
  -H "X-Webhook-Timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -d "$PAYLOAD"
```

---

**Status:** Phase 3 Complete ✅
**Next:** Phase 4 - System Comments & Audit Trails (or enhance existing phases)
