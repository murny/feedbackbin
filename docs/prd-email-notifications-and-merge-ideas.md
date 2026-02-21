# Product Requirements Document: Email Notifications & Merge Duplicate Ideas

## Overview

This PRD covers two high-priority features identified through competitive analysis against Canny, Frill, and Nolt. Both features are table-stakes for customer feedback platforms and represent the most impactful gaps in FeedbackBin's current offering.

---

## Feature 1: Email Notifications for Idea Activity

### Problem Statement

FeedbackBin currently only delivers notifications in-app via Turbo Streams. Users must be actively using the application to see updates about ideas they care about. Every major competitor (Canny, Frill, Nolt) sends email notifications when:

- An idea's status changes (e.g., "Planned" → "In Progress" → "Complete")
- Someone comments on an idea the user is watching
- Someone mentions the user in an idea or comment

Without email notifications, users have no way to know when their feedback has been acknowledged or acted upon. This breaks the "close the loop" feedback cycle that is core to these platforms.

### Goals

1. Notify watchers via email when meaningful events occur on ideas they follow
2. Respect user preferences — allow opting out of email notifications
3. Prevent email fatigue with sensible defaults and batching considerations
4. Build on the existing notification infrastructure (Events, Notifiers, Watches)

### Current Architecture

The existing system provides a strong foundation:

- **Event model** tracks all actions (`idea_created`, `idea_status_changed`, `comment_created`, etc.)
- **Notifier pattern** (`Notifier::IdeaEventNotifier`, `Notifier::CommentEventNotifier`, `Notifier::MentionNotifier`) determines recipients per event type
- **Watch model** tracks which users follow which ideas (with `watching` boolean toggle)
- **NotifyRecipientsJob** runs asynchronously after each event is created
- **Action Mailer** is configured with SendGrid SMTP in production, `letter_opener_web` in development
- **Existing mailers** (`MagicLinkMailer`, `IdentityMailer`, `InvitationsMailer`) provide patterns to follow

### Requirements

#### 1. Notification Mailer

Create `NotificationMailer` that sends emails for the following events:

| Event | Recipients | Email Subject Pattern |
|---|---|---|
| `idea_status_changed` | Idea watchers (excl. actor) | `[Board] Idea title — status changed to X` |
| `comment_created` | Idea watchers (excl. commenter) | `[Board] Idea title — new comment from Name` |
| `mention` (in idea or comment) | Mentioned user | `[Board] Name mentioned you in Idea title` |
| `idea_created` | Board creator (if different) | `[Board] New idea: Idea title` |

Each email should include:
- The idea title and board name
- The specific change or content (status change details, comment body, etc.)
- A direct link to the idea (using `idea_url`)
- An unsubscribe link to stop watching the idea
- Account branding (logo if available)

#### 2. User Email Notification Preferences

Add a `notification_preferences` JSON column to the `users` table (or a separate `notification_preferences` table) with the following settings:

| Preference | Type | Default | Description |
|---|---|---|---|
| `email_notifications` | boolean | `true` | Master toggle for all email notifications |
| `email_on_status_change` | boolean | `true` | Email when a watched idea's status changes |
| `email_on_new_comment` | boolean | `true` | Email when someone comments on a watched idea |
| `email_on_mention` | boolean | `true` | Email when mentioned in an idea or comment |

These preferences should be editable on the user's settings/profile page.

#### 3. Integration with Existing Notifier System

Extend the `Notifier#notify` method (or the `NotifyRecipientsJob`) to:

1. Create the in-app `Notification` record (existing behavior)
2. Check the recipient's email notification preferences
3. If enabled, enqueue a `NotificationEmailJob` to send the email asynchronously
4. Use `deliver_later` to leverage Active Job and Solid Queue

The email delivery should be a **separate job** from the in-app notification creation to ensure in-app notifications are never delayed by email delivery issues.

#### 4. Unsubscribe Mechanism

- Each email includes a one-click unsubscribe link that unwatches the specific idea
- Use Rails' built-in `ActionMailer::Base#unsubscribe` headers (List-Unsubscribe) for email client integration
- Unsubscribe links should use signed tokens (via `Rails.application.message_verifier`) to avoid requiring login

#### 5. Email Template Design

- Use the existing `mailer` layout as a base
- Clean, minimal design consistent with FeedbackBin's aesthetic
- Support both HTML and plain text versions
- Include account branding (logo, name) in the header
- Use I18n for all text strings

### Database Changes

```ruby
# Migration: AddNotificationPreferencesToUsers
add_column :users, :notification_preferences, :json, default: {}, null: false
```

### Non-Goals (v1)

- Email digest/batching (e.g., "You have 5 updates" daily summary) — consider for v2
- Per-board notification preferences — v1 uses per-event-type preferences only
- Email notifications for vote milestones (e.g., "Your idea reached 10 votes") — consider for v2
- Notification for changelog entries — separate feature

### Testing Strategy

- Unit tests for `NotificationMailer` (correct recipients, subjects, content)
- Unit tests for preference checking logic
- Integration tests for the full flow: event → notifier → email job → mailer
- Test unsubscribe token generation and verification
- Test preference defaults for new users
- Test that email delivery failures don't break in-app notifications

---

## Feature 2: Merge Duplicate Ideas

### Problem Statement

As feedback boards grow, duplicate ideas inevitably appear. Currently, admins have no way to consolidate duplicates — they must manually ask users to vote on the "canonical" idea and then delete the duplicate, losing its votes, comments, and watchers in the process.

All three competitors (Canny, Frill, Nolt) offer idea merging that transfers votes, comments, and watchers from a duplicate to a target idea.

### Goals

1. Allow admins to merge one idea into another, consolidating community feedback
2. Transfer all votes, comments, and watchers from the source to the target idea
3. Preserve an audit trail showing that a merge occurred
4. Redirect users who visit the old idea URL to the merged target

### Requirements

#### 1. Merge Action

Admins can select a "source" idea and merge it into a "target" idea. The merge operation:

1. **Moves comments** from source to target (re-parents them under the target idea)
2. **Transfers votes** — voters of the source who haven't already voted on the target get their votes moved. Duplicate voters (voted on both) have their source vote deleted. The target's `votes_count` counter cache is recalculated.
3. **Transfers watchers** — watchers of the source who aren't already watching the target get a watch record on the target. Duplicate watchers have their source watch deleted.
4. **Transfers tags** — tags on the source that don't exist on the target are added
5. **Creates a system comment** on the target: "Merged idea **Source Title** into this idea" with metadata about what was transferred (X votes, Y comments, Z watchers)
6. **Creates an event** (`idea_merged`) on the target for the audit trail
7. **Marks the source as merged** — sets `merged_into_id` on the source idea rather than deleting it, so URLs can redirect

#### 2. Merge UI

**Merge initiation** (from source idea):
- Add "Merge into another idea..." option in the admin action menu on the idea show page
- Opens a dialog/modal with a searchable idea selector (search by title, excluding the current idea and already-merged ideas)
- Shows a preview: "Merge **Source Title** into **Target Title** — this will transfer X votes, Y comments, Z watchers"
- Confirm button to execute the merge

**Post-merge behavior**:
- Redirect to the target idea after merge
- Visiting the source idea's URL redirects (302) to the target idea
- Source idea no longer appears in idea lists or search results
- Source idea's votes/comments are no longer counted in board-level aggregations

#### 3. Database Changes

```ruby
# Migration: AddMergedIntoIdToIdeas
add_column :ideas, :merged_into_id, :integer
add_index :ideas, :merged_into_id
```

The `merged_into_id` column references another idea. When set:
- The idea is considered "merged" and hidden from listings
- Its URL redirects to the target idea
- It can be referenced in system comments and audit trails

#### 4. Model Changes

Add `Idea::Mergeable` concern:

```ruby
module Idea::Mergeable
  extend ActiveSupport::Concern

  included do
    belongs_to :merged_into, class_name: "Idea", optional: true
    has_many :merged_ideas, class_name: "Idea", foreign_key: :merged_into_id

    scope :not_merged, -> { where(merged_into_id: nil) }
  end

  def merged?
    merged_into_id.present?
  end

  def merge_into!(target, merger:)
    # Transfer votes, comments, watchers, tags
    # Create system comment and event
    # Set merged_into_id
  end
end
```

All existing idea queries (`Idea.all`, scopes on index pages, search, roadmap) must be updated to exclude merged ideas using the `not_merged` scope.

#### 5. Controller & Routes

```ruby
# In routes.rb, nested under ideas:
resource :merge, only: [:new, :create], module: :ideas
```

- `GET /ideas/:idea_id/merge/new` — show merge dialog with idea search
- `POST /ideas/:idea_id/merge` — execute the merge (params: `target_idea_id`)
- Authorization: admin or owner only

#### 6. Handling Edge Cases

- **Merged idea is itself a merge target**: Follow the chain — if idea A was merged into B, and B is later merged into C, redirect A → C (resolve to final target)
- **Self-merge**: Prevent merging an idea into itself
- **Already-merged source**: Prevent merging an idea that is already merged
- **Same-board vs cross-board**: Allow merging ideas across different boards (the target's board is kept)
- **Counter cache accuracy**: After transferring votes/comments, reset counter caches on both source and target

### Non-Goals (v1)

- Undo/unmerge — once merged, the operation is permanent (admin-only action, treat as deliberate)
- Automatic duplicate detection / AI suggestions — consider for v2
- Bulk merge (merge multiple ideas at once) — v1 supports one-at-a-time only
- Merge history page — the system comment on the target provides sufficient audit trail

### Testing Strategy

- Unit tests for `Idea::Mergeable` concern (vote transfer, comment transfer, watcher transfer, tag transfer)
- Test counter cache recalculation after merge
- Test redirect behavior for merged idea URLs
- Test that merged ideas are excluded from all listings and search
- Test merge chain resolution (A→B→C redirects A to C)
- Test authorization (only admins can merge)
- Controller tests for the merge action (success, validation errors, edge cases)
- System test for the merge UI flow (search, select, confirm, redirect)

---

## Implementation Order

1. **Email Notifications** — higher user impact, builds on existing infrastructure
   - Phase 1: `NotificationMailer` + email sending on events
   - Phase 2: User preferences + unsubscribe mechanism
   - Phase 3: Email template polish + testing

2. **Merge Duplicate Ideas** — requires more schema changes but is self-contained
   - Phase 1: Database migration + `Idea::Mergeable` concern + merge logic
   - Phase 2: Controller + merge UI dialog
   - Phase 3: Redirect handling + exclude merged from listings + testing

---

## Success Metrics

### Email Notifications
- Email open rate > 30% (indicates relevant, non-spammy content)
- Unsubscribe rate < 5% per email (indicates appropriate frequency)
- Increase in return visits after status change emails

### Merge Duplicate Ideas
- Reduction in duplicate ideas on boards
- Admin usage of merge feature (adoption)
- No orphaned votes/comments after merges (data integrity)
