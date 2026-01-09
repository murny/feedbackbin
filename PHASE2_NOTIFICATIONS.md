# Phase 2: Notifications System

## Overview

Phase 2 builds on the events system from Phase 1 to provide automatic user notifications. When events occur (idea created, status changed, comments added), relevant users are notified in real-time.

## What We Built

### 1. Database Schema

**Migration:** `db/migrate/20251230202000_create_notifications.rb`

```ruby
create_table :notifications do |t|
  t.bigint :user_id, null: false        # Who receives the notification
  t.bigint :creator_id, null: false     # Who triggered the event
  t.bigint :source_id, null: false      # Polymorphic (Event)
  t.string :source_type, null: false    # "Event" for now
  t.datetime :read_at                   # Timestamp for marking as read
  t.timestamps
end
```

**Key indexes:**
- `user_id`, `creator_id` - for user lookups
- `[source_type, source_id]` - polymorphic source
- `[user_id, read_at]` - unread notifications query
- `[user_id, created_at]` - recent notifications

### 2. Core Models & Architecture

#### Notification Model (`app/models/notification.rb`)
- **Belongs to:** user (recipient), creator, source (Event)
- **Delegates:** `description_for` to source event
- **Scopes:** `unread`, `read`, `recent`
- **Methods:**
  - `mark_as_read!` / `mark_as_unread!`
  - `read?` / `unread?`
  - `url` - generates link to notification subject

**Real-time broadcasts:**
```ruby
after_create_commit :broadcast_unread_count
after_update_commit :broadcast_unread_count, if: :saved_change_to_read_at?
```

#### Notifiable Concern (`app/models/concerns/notifiable.rb`)
Included in Event model to enable automatic notification creation:

```ruby
included do
  has_many :notifications, as: :source
  after_create_commit :notify_recipients_later
end
```

**Flow:**
1. Event created
2. `after_create_commit` triggers `notify_recipients_later`
3. `NotifyRecipientsJob` enqueued
4. Job calls `event.notify_recipients`
5. Notifier factory creates appropriate notifier
6. Notifier creates Notification records
7. Each notification broadcasts unread count update

### 3. Notifier System (Factory Pattern)

#### Base Notifier (`app/models/notifier.rb`)
Factory class that routes to appropriate notifier based on event type:

```ruby
Notifier.for(event)  # Returns IdeaEventNotifier or CommentEventNotifier
  .notify            # Creates Notification records
```

**Architecture:**
- `self.for(source)` - Factory method to find correct notifier class
- `notify()` - Creates notifications for all recipients
- `recipients` - Override in subclasses to define who gets notified
- `should_notify?` - Override to conditionally prevent notifications

#### IdeaEventNotifier (`app/models/notifier/idea_event_notifier.rb`)
Handles notifications for Idea events:

| Event Type | Recipients |
|------------|-----------|
| `idea_created` | Board creator (if different from idea creator) |
| `idea_status_changed` | Idea creator (if they didn't make the change) |
| `idea_board_changed` | Idea creator (if they didn't make the change) |
| `idea_title_changed` | Idea creator (if they didn't make the change) |

**Future enhancement:** Notify board watchers/followers

#### CommentEventNotifier (`app/models/notifier/comment_event_notifier.rb`)
Handles notifications for Comment events:

| Event Type | Recipients |
|------------|-----------|
| `comment_created` | 1. Idea creator (if they didn't write comment)<br>2. All other commenters on the idea |

**Key feature:** Automatically notifies everyone participating in the discussion

### 4. Background Jobs

#### NotifyRecipientsJob (`app/jobs/notify_recipients_job.rb`)
Asynchronous job for creating notifications:

```ruby
def perform(notifiable)
  notifiable.notify_recipients  # Calls Notifier.for(notifiable).notify
end
```

**Queue:** `default`
**Triggered by:** Event `after_create_commit`

### 5. Controller & Routes

#### NotificationsController (`app/controllers/notifications_controller.rb`)
- `GET /notifications` - List user's notifications
- `PATCH /notifications/:id` - Mark as read/unread
- `POST /notifications/mark_all_read` - Mark all as read

**Security:** All actions scoped to `Current.user.notifications`

#### Routes
```ruby
resources :notifications, only: [:index, :update] do
  collection do
    post :mark_all_read
  end
end
```

### 6. Views & UI

#### Notification Index (`app/views/notifications/index.html.erb`)
- Shows recent 50 notifications
- "Mark all as read" button (if unread exist)
- Empty state for no notifications
- Visual distinction for unread (highlighted background)

#### Notification Partial (`app/views/notifications/_notification.html.erb`)
Displays individual notification with:
- Event description (from `Event::Description`)
- Time ago
- Unread indicator (blue dot)
- "View" link to subject (Idea or Comment)
- Mark as read/unread button

#### Unread Count Badge (`app/views/notifications/_unread_count.html.erb`)
Real-time updating badge:
```erb
<span class="...">
  <%= count > 99 ? "99+" : count %>
</span>
```

**Broadcasts to:** `[user, :notifications]` stream
**Target:** `#unread_notifications_count`

### 7. I18n Translations

Added to `config/locales/en.yml`:

```yaml
notifications:
  index:
    all_caught_up: You're all caught up!
    heading: Notifications
    mark_all_read: Mark all as read
    no_notifications: No notifications yet
    title: Notifications
  mark_all_read:
    all_marked_as_read: All notifications marked as read
  update:
    marked_as_read: Notification marked as read
    marked_as_unread: Notification marked as unread
```

## How It Works

### Complete Notification Flow

```
1. User creates a comment on an idea
   ↓
2. Comment#after_create_commit triggers track_event(:created)
   ↓
3. Event created with action: "comment_created"
   ↓
4. Event#after_create_commit triggers notify_recipients_later
   ↓
5. NotifyRecipientsJob.perform_later(event)
   ↓
6. Job runs: Notifier.for(event).notify
   ↓
7. CommentEventNotifier determines recipients:
   - Idea creator (if not commenter)
   - All other commenters on idea
   ↓
8. Notification.create! for each recipient
   ↓
9. Each notification broadcasts unread count update
   ↓
10. User's UI updates in real-time via Turbo Streams
```

### Example Scenarios

#### Scenario 1: Status Change Notification
```ruby
# Admin changes idea status
idea.update(status: in_progress_status)

# Event created automatically (Phase 1)
event = Event.last
# => action: "idea_status_changed"
# => creator: admin_user
# => eventable: idea

# Notification created automatically (Phase 2)
notification = Notification.last
# => user: idea.creator
# => source: event
# => read_at: nil (unread)

# User sees notification
notification.description_for(idea.creator).to_html
# => "<strong>Admin Name</strong> changed the status of <strong>Feature Request</strong> to <strong>In Progress</strong>"
```

#### Scenario 2: Comment Thread Notifications
```ruby
# Alice creates idea
idea = Idea.create!(title: "Add dark mode", creator: alice)

# Bob comments
comment1 = Comment.create!(idea: idea, creator: bob, body: "Great idea!")
# => Notification created for Alice

# Charlie comments
comment2 = Comment.create!(idea: idea, creator: charlie, body: "I agree!")
# => Notifications created for:
#    - Alice (idea creator)
#    - Bob (previous commenter)

# Alice comments back
comment3 = Comment.create!(idea: idea, creator: alice, body: "Thanks!")
# => Notifications created for:
#    - Bob (previous commenter)
#    - Charlie (previous commenter)
#    - NOT Alice (she wrote the comment)
```

## Integration with Phase 1

Phase 2 seamlessly integrates with Phase 1's events system:

| Phase 1 | Phase 2 |
|---------|---------|
| Event created | Notification job enqueued |
| Event.description_for(user) | Used in notification display |
| Event.eventable (polymorphic) | Notification.url links to it |
| Event.creator | Notification.creator (who triggered) |
| Event.particulars | Available in notification context |

## Benefits

1. **Automatic Notifications** - No manual notification code needed
2. **Smart Recipients** - Context-aware recipient selection
3. **Conversation Tracking** - Stay updated on discussions
4. **Real-time Updates** - Instant UI updates via Turbo Streams
5. **Extensible** - Easy to add new notification types
6. **User Control** - Mark as read/unread, view history

## Performance Considerations

- **Background Jobs** - Notification creation doesn't block requests
- **Efficient Queries** - Proper indexes for `user_id`, `read_at`, `created_at`
- **Limited Results** - Index page shows only 50 most recent
- **Eager Loading** - `includes(:creator, source: :eventable)` prevents N+1

## Future Enhancements (Phase 3+)

### Notification Preferences
- [ ] User settings for notification types
- [ ] Email digest vs real-time
- [ ] Mute specific ideas/boards

### Watchers System
- [ ] Explicit "watch" button on ideas
- [ ] Auto-watch when creating/commenting
- [ ] Notify watchers of all changes

### Grouping & Batching
- [ ] Group similar notifications ("3 new comments on...")
- [ ] Batch notifications within time window
- [ ] Collapse old notifications

### Push Notifications
- [ ] Browser push notifications
- [ ] Mobile app notifications
- [ ] Desktop notifications

### Email Notifications
- [ ] Instant email for important events
- [ ] Daily/weekly digest emails
- [ ] Unsubscribe links

## Files Created/Modified

**New files:**
- `db/migrate/20251230202000_create_notifications.rb`
- `app/models/notification.rb`
- `app/models/concerns/notifiable.rb`
- `app/models/notifier.rb`
- `app/models/notifier/idea_event_notifier.rb`
- `app/models/notifier/comment_event_notifier.rb`
- `app/jobs/notify_recipients_job.rb`
- `app/controllers/notifications_controller.rb`
- `app/views/notifications/index.html.erb`
- `app/views/notifications/_notification.html.erb`
- `app/views/notifications/_unread_count.html.erb`

**Modified files:**
- `app/models/event.rb` - Added `include Notifiable`
- `app/models/user.rb` - Added `has_many :notifications`
- `config/routes.rb` - Added notifications routes
- `config/locales/en.yml` - Added notification translations

## Testing Notifications

```ruby
# In rails console
# Create an idea
idea = Idea.create!(title: "Test Idea", board: Board.first, creator: User.first)

# Check event was created
Event.last.action  # => "idea_created"

# Wait a moment for job to process
sleep 1

# Check notification was created
Notification.last.user  # => Board.first.creator (if different from idea creator)

# Change status
idea.update(status: Status.first)

# Check new event and notification
Event.last.action  # => "idea_status_changed"
Notification.last.user  # => User.first (idea creator)

# View notification as user
notification = Notification.last
notification.description_for(notification.user).to_html
notification.url  # => Link to idea

# Mark as read
notification.mark_as_read!
notification.read?  # => true
```

---

**Status:** Phase 2 Complete ✅
**Next:** Phase 3 - Webhooks
