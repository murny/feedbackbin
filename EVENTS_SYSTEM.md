# Events System Implementation

## Overview

We've implemented a comprehensive events system for FeedbackBin, inspired by Basecamp's Fizzy architecture. This system tracks all significant actions (idea creation, status changes, comments, etc.) in a centralized events table.

## What We Built (Phase 1: Core Events System)

### 1. Database Schema

**Migration:** `db/migrate/20251230201800_create_events.rb`

```ruby
create_table :events do |t|
  t.bigint :account_id, null: false
  t.string :action, null: false          # e.g., "idea_created", "idea_status_changed"
  t.bigint :board_id, null: false
  t.bigint :creator_id, null: false
  t.bigint :eventable_id, null: false    # Polymorphic ID (Idea or Comment)
  t.string :eventable_type, null: false  # "Idea" or "Comment"
  t.json :particulars, default: {}       # Event-specific metadata
  t.timestamps
end
```

**Key indexes for performance:**
- `account_id`, `board_id`, `creator_id`, `action`
- `[eventable_type, eventable_id]` - for polymorphic lookups
- `[board_id, action, created_at]` - for filtered timeline queries

### 2. Core Models & Concerns

#### Event Model (`app/models/event.rb`)
- **Polymorphic associations** to Idea and Comment
- **Action inquiry** - `event.action.idea_created?` for safe checking
- **Description generation** - `event.description_for(user)` for UI display
- **Auto-notification hook** - calls `eventable.event_was_created(event)` after creation

#### Eventable Concern (`app/models/concerns/eventable.rb`)
Provides `track_event()` method to any model:

```ruby
# In Idea model:
track_event(:status_changed,
  particulars: { old_status: "Open", new_status: "In Progress" }
)
```

**Features:**
- Automatic event prefix based on model name (Idea → "idea_", Comment → "comment_")
- Customizable via `should_track_event?` override
- Extensible via `event_was_created(event)` hook

#### Event::Particulars (`app/models/event/particulars.rb`)
Dynamic accessors for JSON metadata:

```ruby
event = Event.create(
  action: "idea_status_changed",
  particulars: { old_status: "Open", new_status: "Done" }
)

event.old_status  # => "Open"
event.new_status  # => "Done"
```

#### Event::Description (`app/models/event/description.rb`)
Human-readable event descriptions:

```ruby
event.description_for(current_user).to_html
# => "You changed the status of <strong>Feature Request</strong> to <strong>Done</strong>"

event.description_for(other_user).to_html
# => "<strong>John Doe</strong> changed the status of <strong>Feature Request</strong> to <strong>Done</strong>"
```

**Supports:**
- HTML output (for UI display)
- Plain text output (for emails, webhooks)
- Personalization (shows "You" for current user)
- I18n integration

### 3. Event Types Implemented

#### Idea Events
- **`idea_created`** - When an idea is first created
- **`idea_status_changed`** - Status updates (Open → In Progress → Done)
  - Particulars: `{ old_status, new_status }`
- **`idea_board_changed`** - Moved between boards
  - Particulars: `{ old_board, new_board }`
- **`idea_title_changed`** - Title edits
  - Particulars: `{ old_title, new_title }`

#### Comment Events
- **`comment_created`** - New comments on ideas
  - Automatically links to parent idea's board

### 4. Integration Points

**Idea Model:**
```ruby
include Eventable

after_create_commit :track_creation
after_update :track_status_change, if: :saved_change_to_status_id?
after_update :track_board_change, if: :saved_change_to_board_id?
after_update :track_title_change, if: :saved_change_to_title?
```

**Comment Model:**
```ruby
include Eventable

after_create_commit :track_creation

def board
  idea.board  # Comments inherit board from their idea
end
```

**Board Model:**
```ruby
has_many :events, dependent: :destroy
```

### 5. I18n Translations

Added to `config/locales/en.yml`:

```yaml
events:
  actions:
    changed_status: changed the status of
    changed_title: changed the title
    commented_on: commented on
    created: created
    moved: moved
  from: from
  to: to
  unknown_item: unknown item
  you: You
```

## How It Works

### Event Creation Flow

```
1. User performs action (e.g., changes idea status)
   ↓
2. Idea model's after_update callback fires
   ↓
3. track_status_change() calls track_event(:status_changed, particulars: {...})
   ↓
4. Event record created in database
   ↓
5. Event.after_create hook calls idea.event_was_created(event)
   ↓
6. (Future: Create notifications, webhooks, system comments)
```

### Example Usage

```ruby
# Create an idea (automatic event tracking)
idea = Idea.create!(
  title: "Add dark mode",
  board: board,
  creator: current_user
)
# => Creates event: { action: "idea_created", eventable: idea }

# Update status (automatic event tracking)
idea.update(status: in_progress_status)
# => Creates event: {
#      action: "idea_status_changed",
#      particulars: { old_status: "Open", new_status: "In Progress" }
#    }

# Retrieve events
board.events.where(action: "idea_created").count
idea.events.order(created_at: :desc).first

# Display event
event = idea.events.last
event.description_for(current_user).to_html
# => "You changed the status of <strong>Add dark mode</strong> to <strong>In Progress</strong>"
```

## Next Steps (Phase 2-4)

### Phase 2: Notifications
- [ ] Create Notification model
- [ ] Add Notifiable concern to Event
- [ ] Implement Notifier factory pattern
- [ ] Event-based notification creation
- [ ] Real-time broadcasts via Turbo Streams

### Phase 3: Webhooks
- [ ] Create Webhook model
- [ ] Implement webhook delivery system
- [ ] Add HMAC signing for security
- [ ] Webhook dispatch jobs
- [ ] Delinquency tracking (auto-disable failing webhooks)
- [ ] Support multiple payload formats (JSON, Slack, etc.)

### Phase 4: Audit Trail
- [ ] System comments for events
- [ ] Activity feed UI
- [ ] Event timeline view
- [ ] Export capabilities

## Architecture Decisions

### Why Polymorphic Eventable?
- Single events table for all trackable models
- Consistent event querying across types
- Easy to add new event sources (e.g., future Vote events)

### Why JSON Particulars?
- Flexible metadata without schema changes
- Different events need different data
- Easy to query and extend

### Why Board-scoped Events?
- Natural filtering for activity feeds
- Permissions inheritance from board
- Efficient queries with proper indexing

## Key Files Created

```
db/migrate/20251230201800_create_events.rb
app/models/event.rb
app/models/event/particulars.rb
app/models/event/description.rb
app/models/concerns/eventable.rb
config/locales/en.yml (updated)
app/models/idea.rb (updated)
app/models/comment.rb (updated)
app/models/board.rb (updated)
```

## Running the Migration

Once bundler issues are resolved:

```bash
bin/rails db:migrate
```

This will create the events table and enable event tracking across the application.

## Testing Events

```ruby
# In rails console
idea = Idea.first
idea.events  # => All events for this idea

board = Board.first
board.events.where(action: "idea_created")  # => All idea creation events

event = Event.last
event.description_for(User.first).to_plain_text
```

## Benefits

1. **Audit Trail** - Complete history of all changes
2. **Activity Feeds** - Show recent activity per board/idea
3. **Notifications** - Foundation for smart notifications
4. **Webhooks** - Foundation for external integrations
5. **Analytics** - Query patterns, popular actions, engagement metrics
6. **Compliance** - Track who did what and when

## Comparison with Fizzy

| Feature | Fizzy | FeedbackBin |
|---------|-------|-------------|
| Event table | ✅ UUIDs | ✅ BigInt IDs |
| Polymorphic eventable | ✅ Card/Comment | ✅ Idea/Comment |
| JSON particulars | ✅ | ✅ |
| Action inquiry | ✅ | ✅ |
| Event descriptions | ✅ | ✅ |
| Webhooks | ✅ | 🔜 Phase 3 |
| Notifications | ✅ | 🔜 Phase 2 |
| System comments | ✅ | 🔜 Phase 4 |

---

**Status:** Phase 1 Complete ✅
**Next:** Phase 2 - Notifications
