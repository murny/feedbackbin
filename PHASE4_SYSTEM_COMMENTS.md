# Phase 4: System Comments & Audit Trail

## Overview

Phase 4 adds visible audit trails by automatically creating system comments for events. When ideas change (status updates, title edits, board moves), system comments appear in the comment thread showing exactly what happened and who did it.

This provides users with a clear, chronological history directly on the idea page without needing to query the events table.

## What We Built

### 1. System Commenter

**File:** `app/models/idea/system_commenter.rb`

Follows Fizzy's pattern of generating human-readable descriptions for events and creating comments from the system user.

```ruby
class Idea::SystemCommenter
  def initialize(idea, event)
    @idea = idea
    @event = event
  end

  def comment
    return unless comment_body.present?

    idea.comments.create!(
      creator: idea.account.system_user,  # System user (role: :system)
      body: comment_body,
      created_at: event.created_at        # Match event timestamp
    )
  end

  private
    def comment_body
      case event.action.to_s
      when "idea_status_changed"
        "#{creator_name} <strong>changed the status</strong> from \"#{old_status}\" to \"#{new_status}\""
      when "idea_board_changed"
        "#{creator_name} <strong>moved</strong> this from \"#{old_board}\" to \"#{new_board}\""
      when "idea_title_changed"
        "#{creator_name} <strong>changed the title</strong> from \"#{old_title}\" to \"#{new_title}\""
      end
    end
end
```

**Key features:**
- **HTML-safe output** - Uses `ERB::Util#h` to escape user input
- **Event-specific formatting** - Different messages for different events
- **Timestamp preservation** - System comment created_at matches event created_at
- **System user attribution** - All system comments come from `account.system_user`

### 2. Event Integration

**Updated:** `app/models/idea.rb`

Added `event_was_created` callback that's triggered by the Event model after event creation.

```ruby
class Idea < ApplicationRecord
  include Eventable  # Provides track_event() method

  # Called by Event after creation (via Eventable concern)
  # Creates system comments for visible audit trail
  def event_was_created(event)
    create_system_comment_for(event)
  end

  private
    def create_system_comment_for(event)
      Idea::SystemCommenter.new(self, event).comment
    end
end
```

**Flow:**
1. Idea updated (e.g., status changed)
2. `after_update` callback triggers `track_status_change`
3. `track_event(:status_changed, ...)` creates Event
4. Event `after_create` callback calls `idea.event_was_created(event)`
5. `Idea::SystemCommenter` creates system comment
6. System comment appears in comment thread

### 3. System User

**Existing:** `app/models/account.rb`

FeedbackBin already has system user support:

```ruby
def self.create_with_owner(account:, owner:)
  create!(**account).tap do |account|
    account.users.create!(role: :system, name: "System")  # Creates system user
    account.users.create!(**owner.reverse_merge(role: :owner, verified_at: Time.current))
  end
end

def system_user
  users.find_by!(role: :system)
end
```

**Existing:** `app/models/user/role.rb`

The Role enum already includes `:system`:

```ruby
enum :role, [ :owner, :admin, :member, :system, :bot ].index_by(&:itself)
```

This automatically provides:
- `user.system?` - Check if user is system
- `user.role.system?` - Alternative syntax

### 4. Visual Styling

**Updated:** `app/views/comments/_comment.html.erb` and `app/views/comments/_reply.html.erb`

System comments are styled differently to distinguish them from user comments.

#### Regular Comment (User)
```erb
<div class="p-4 lg:p-6 mb-6 text-base bg-card border border-border rounded-lg">
  <div class="flex">
    <div class="mr-4">
      <%= render partial: "votes/vote_button", locals: { voteable: comment } %>
    </div>
    <div class="w-full">
      <!-- Avatar, name, timestamp, dropdown menu -->
      <!-- Comment body -->
    </div>
  </div>
</div>
```

#### System Comment
```erb
<% if comment.creator.system? %>
  <div class="p-3 mb-4 text-sm bg-muted/30 border border-muted rounded-lg">
    <div class="flex items-center gap-2">
      <%= lucide_icon("info", class: "w-4 h-4 text-muted-foreground") %>
      <div class="flex-1">
        <p class="text-muted-foreground">
          <%= comment.body.html_safe %>
        </p>
      </div>
      <%= local_datetime_tag comment.created_at, style: :datetime, class: "text-xs text-muted-foreground" %>
    </div>
  </div>
<% end %>
```

**Visual differences:**
- **Lighter background** - `bg-muted/30` instead of `bg-card`
- **Smaller padding** - `p-3` instead of `p-4 lg:p-6`
- **No vote button** - System comments aren't voteable
- **No dropdown menu** - Can't edit/delete system comments
- **Info icon** - Shows `info` icon instead of avatar
- **Smaller text** - `text-sm` for more subtle appearance
- **Timestamp inline** - Shown at end of line, not below

### 5. Comment Examples

#### Status Change
```
ℹ Alice changed the status from "Open" to "In Progress"  2m ago
```

#### Board Move
```
ℹ Bob moved this from "Feature Requests" to "Bug Reports"  1h ago
```

#### Title Edit
```
ℹ Charlie changed the title from "Bug fix" to "Critical bug fix"  3d ago
```

## How It Works

### Complete Flow

```
1. User changes idea status
   idea.update(status: in_progress_status)
   ↓
2. Idea after_update callback fires
   ↓
3. track_status_change() called
   ↓
4. track_event(:status_changed, particulars: { old_status: "Open", new_status: "In Progress" })
   ↓
5. Event created in database
   ↓
6. Event after_create callback: eventable.event_was_created(self)
   ↓
7. idea.event_was_created(event) called
   ↓
8. create_system_comment_for(event)
   ↓
9. Idea::SystemCommenter.new(idea, event).comment
   ↓
10. System comment created:
    creator: account.system_user
    body: "Alice <strong>changed the status</strong> from \"Open\" to \"In Progress\""
    created_at: event.created_at
   ↓
11. Comment appears in idea's comment thread with special styling
```

### Example Scenario

```ruby
# User creates idea
idea = Idea.create!(
  title: "Add dark mode",
  board: features_board,
  creator: alice
)

# Check comments - no system comment for creation
idea.comments.count  # => 0

# User changes status
idea.update(status: Status.find_by(name: "In Progress"))

# System comment created automatically
idea.comments.reload.count  # => 1
comment = idea.comments.last

comment.creator.system?  # => true
comment.body
# => "Alice <strong>changed the status</strong> from \"Open\" to \"In Progress\""

# User changes title
idea.update(title: "Add dark mode support")

# Another system comment
idea.comments.count  # => 2
idea.comments.last.body
# => "Alice <strong>changed the title</strong> from \"Add dark mode\" to \"Add dark mode support\""

# User adds regular comment
idea.comments.create!(
  creator: bob,
  body: "Great progress!"
)

# Now we have 2 system comments + 1 user comment
idea.comments.count  # => 3
idea.comments.where(creator: alice.account.system_user).count  # => 2
```

### Comment Thread Display

```
┌─────────────────────────────────────────────────┐
│ Add dark mode support                           │
│ Created by Alice · 1h ago                       │
├─────────────────────────────────────────────────┤
│ ℹ Alice changed the status from "Open" to      │
│   "In Progress"  30m ago                        │
├─────────────────────────────────────────────────┤
│ ℹ Alice changed the title from "Add dark mode" │
│   to "Add dark mode support"  15m ago           │
├─────────────────────────────────────────────────┤
│ 👤 Bob                                          │
│ Great progress!  5m ago                         │
│ [Vote] [Reply] [...]                            │
└─────────────────────────────────────────────────┘
```

## Event Type Coverage

| Event Type | System Comment Created | Example |
|------------|----------------------|---------|
| `idea_created` | ❌ No | Idea itself is the record |
| `idea_status_changed` | ✅ Yes | "Alice changed the status from 'Open' to 'In Progress'" |
| `idea_board_changed` | ✅ Yes | "Bob moved this from 'Features' to 'Bugs'" |
| `idea_title_changed` | ✅ Yes | "Charlie changed the title from 'X' to 'Y'" |
| `comment_created` | ❌ No | Comment itself is visible |

**Rationale:**
- **No system comment for idea_created** - The idea creation is self-evident
- **No system comment for comment_created** - User comments speak for themselves
- **System comments for changes** - Status, board, and title changes need visibility

## Benefits

### 1. User-Visible History
Users can see the complete evolution of an idea without leaving the page:
- What changed
- Who changed it
- When it changed
- Previous vs new values

### 2. Chronological Context
System comments appear in chronological order with user comments, providing narrative flow:

```
[Alice creates idea]
[Bob comments: "This would be useful"]
[System: Alice changed status to "In Review"]
[Charlie comments: "When will this be ready?"]
[System: Alice changed status to "Done"]
[Alice comments: "Shipped yesterday!"]
```

### 3. Audit Compliance
Provides immutable audit trail:
- Created by system user (can't be edited/deleted by regular users)
- Timestamp matches event creation
- HTML content preserved exactly as generated

### 4. No Additional Tables
Reuses existing Comment model and infrastructure:
- No new tables needed
- Works with existing comment UI
- Leverages existing comment ordering/pagination
- System comments included in exports

### 5. Searchable History
System comments are searchable like regular comments:
```ruby
# Find all ideas where status was changed to "Done"
Comment.joins(:idea)
  .where(creator: account.system_user)
  .where("body LIKE ?", "%status% to \"Done\"")
```

## Security Considerations

### System User Protection

**Already implemented:**
- System user has `role: :system` (not :owner, :admin, or :member)
- System user has no identity (can't log in)
- Comment edit/delete UI hidden for system comments

**Additional considerations:**
- System comments should not be editable via API
- System comments should not be deletable (except cascade delete)
- System user should not be deletable
- System user should not be assignable to regular users

### HTML Safety

System comments use HTML for formatting (`<strong>` tags):
```ruby
"#{creator_name} <strong>changed the status</strong> from \"#{old_status}\" to \"#{new_status}\""
```

**Protection:**
- `ERB::Util#h` escapes all user-provided data (names, titles, statuses)
- Only known-safe HTML (`<strong>`, `\"`) is included unescaped
- View uses `comment.body.html_safe` to render formatted output
- XSS attacks prevented by escaping all dynamic content

Example:
```ruby
idea.update(title: "<script>alert('xss')</script>")

# System comment body:
"Alice <strong>changed the title</strong> from \"Add dark mode\" to \"&lt;script&gt;alert(&#39;xss&#39;)&lt;/script&gt;\""
# Rendered safely - script tags escaped
```

## Integration with Previous Phases

| Phase | Integration Point |
|-------|------------------|
| **Phase 1 (Events)** | System comments created from Event.after_create callback |
| **Phase 2 (Notifications)** | System comments don't trigger notifications (creator.system?) |
| **Phase 3 (Webhooks)** | System comment events could trigger webhooks (comment_created) |

**Notification behavior:**
```ruby
class Notifier::CommentEventNotifier < Notifier
  def should_notify?
    !creator.system?  # Don't notify for system comments
  end
end
```

## Future Enhancements

### Phase 4.5: Enhanced System Comments

- [ ] **Assignment tracking** - "Alice assigned this to Bob"
- [ ] **Priority changes** - "Charlie increased priority to High"
- [ ] **Tag modifications** - "Bob added tags: bug, urgent"
- [ ] **Due date updates** - "Alice set due date to Jan 15"
- [ ] **Attachment uploads** - "Bob attached screenshot.png"
- [ ] **Watchers** - "Alice started watching this"

### Phase 4.6: Activity Aggregation

- [ ] **Combine rapid changes** - "Alice changed status 3 times in 5 minutes"
- [ ] **Daily summaries** - "5 changes yesterday by Alice, Bob, Charlie"
- [ ] **Batch operations** - "Admin moved 12 ideas to 'Done'"

### Phase 4.7: Activity Timeline UI

- [ ] **Filterable timeline** - Show/hide system comments
- [ ] **Activity feed** - All changes across all ideas
- [ ] **User activity history** - Everything Alice changed
- [ ] **Board activity** - Recent changes in this board

## Comparison with Fizzy

| Feature | Fizzy | FeedbackBin |
|---------|-------|-------------|
| System user | ✅ `account.system_user` | ✅ `account.system_user` |
| SystemCommenter class | ✅ `Card::Eventable::SystemCommenter` | ✅ `Idea::SystemCommenter` |
| Event hook | ✅ `event_was_created` | ✅ `event_was_created` |
| HTML formatting | ✅ `<strong>` tags | ✅ `<strong>` tags |
| HTML escaping | ✅ `ERB::Util#h` | ✅ `ERB::Util#h` |
| Timestamp matching | ✅ `created_at: event.created_at` | ✅ `created_at: event.created_at` |
| Visual styling | ✅ Lighter background | ✅ `bg-muted/30` + info icon |
| Assignment tracking | ✅ Yes | ❌ Not yet |
| Postponement tracking | ✅ Yes | ❌ Not yet (no postponement feature) |

## Files Created/Modified

**New files:**
- `app/models/idea/system_commenter.rb` - System comment generator

**Modified files:**
- `app/models/idea.rb` - Added `event_was_created` callback
- `app/views/comments/_comment.html.erb` - Conditional system comment styling
- `app/views/comments/_reply.html.erb` - Conditional system comment styling

**No changes needed:**
- `app/models/account.rb` - Already has `system_user` method
- `app/models/user/role.rb` - Already has `:system` role enum
- `app/models/comment.rb` - Works as-is with system creator

## Testing System Comments

```ruby
# In rails console

# Get idea
idea = Idea.first

# Change status
old_status_name = idea.status_name
idea.update(status: Status.last)

# Check system comment was created
comment = idea.comments.reload.last
comment.creator.system?  # => true
comment.body
# => "Your Name <strong>changed the status</strong> from \"Open\" to \"Done\""

# Change title
idea.update(title: "New Title")

# Check another system comment
idea.comments.count  # => 2 (if no other comments)
idea.comments.last.body
# => "Your Name <strong>changed the title</strong> from \"Old Title\" to \"New Title\""

# Move boards
idea.update(board: Board.last)

# Check board move comment
idea.comments.last.body
# => "Your Name <strong>moved</strong> this from \"Board A\" to \"Board B\""

# View all system comments
idea.comments.joins(:creator).where(users: { role: :system })
```

### Verifying Visual Styling

Visit an idea page after making changes and verify:
- ✅ System comments have lighter background
- ✅ System comments show info icon (not avatar)
- ✅ System comments have no vote button
- ✅ System comments have no dropdown menu
- ✅ System comments have smaller text
- ✅ Timestamp shown inline at end
- ✅ HTML formatting renders correctly (`<strong>` tags)
- ✅ User-provided text is escaped (no XSS)

---

**Status:** Phase 4 Complete ✅
**Next:** Optional enhancements (assignment tracking, watchers, delinquency tracking, etc.)
