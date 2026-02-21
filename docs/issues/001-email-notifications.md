# Email Notifications for Idea Activity

**Labels:** `feature`, `notifications`, `email`

## Summary

Add email notifications so users are informed about activity on ideas they watch, even when they're not actively using FeedbackBin. This is a table-stakes feature — all competitors (Canny, Frill, Nolt) support email notifications for status changes, new comments, and mentions.

Currently, notifications are only delivered in-app via Turbo Streams, which means users must be online and logged in to see updates. This breaks the critical "close the loop" feedback cycle.

## Motivation

- Users submit feedback but never learn when it's been acknowledged or shipped
- Support/product teams change idea statuses but watchers aren't notified outside the app
- @mentions are missed if the user isn't actively browsing
- Every competitor sends emails for these events — users expect it

## Requirements

### 1. NotificationMailer

Create a mailer that sends emails for these events:

| Event | Recipients | Subject Pattern |
|---|---|---|
| `idea_status_changed` | Idea watchers (excl. actor) | `[Board] Idea title — status changed to X` |
| `comment_created` | Idea watchers (excl. commenter) | `[Board] Idea title — new comment from Name` |
| `mention` | Mentioned user | `[Board] Name mentioned you in Idea title` |
| `idea_created` | Board creator (if different) | `[Board] New idea: Idea title` |

Each email should include:
- Idea title and board name
- The specific change or content (status transition, comment body, mention context)
- Direct link to the idea
- One-click unsubscribe link (unwatches the idea without requiring login)
- Account branding (logo/name)

### 2. User Notification Preferences

Add `notification_preferences` JSON column to `users` table:

```ruby
add_column :users, :notification_preferences, :json, default: {}, null: false
```

Default preferences (all enabled):
- `email_notifications` — master toggle
- `email_on_status_change` — watched idea status changes
- `email_on_new_comment` — new comments on watched ideas
- `email_on_mention` — when mentioned in an idea or comment

Add UI for these preferences on the user settings page.

### 3. Integration with Existing System

The notification infrastructure already handles recipient selection well:

- `Notifier::IdeaEventNotifier` — determines recipients for idea events
- `Notifier::CommentEventNotifier` — determines recipients for comment events
- `Notifier::MentionNotifier` — determines recipients for mentions
- `NotifyRecipientsJob` — runs async after event creation
- `Watch` model — tracks who follows which ideas

Extend `Notifier#notify` to also enqueue email delivery via a separate `NotificationEmailJob`, checking user preferences before sending. Email delivery must be a **separate job** so in-app notification creation is never delayed by email issues.

### 4. Unsubscribe

- Each email includes a signed unsubscribe link (via `Rails.application.message_verifier`)
- Clicking it unwatches the specific idea without requiring login
- Set `List-Unsubscribe` headers for email client one-click unsubscribe support

### 5. Email Templates

- HTML + plain text versions
- Use existing `mailer` layout as base
- All text via I18n
- Consistent with FeedbackBin's visual style

## Out of Scope (v1)

- Email digests / batching (daily summary of activity)
- Per-board notification preferences
- Vote milestone notifications ("Your idea reached 10 votes")
- Changelog email notifications

## Technical Notes

- Action Mailer is already configured (SendGrid SMTP in production, letter_opener_web in development)
- Existing mailers (`MagicLinkMailer`, `IdentityMailer`, `InvitationsMailer`) provide patterns to follow
- Use `deliver_later` with Solid Queue for async delivery
- Existing `Event::Description` can generate email copy (`to_plain_text`, `to_html`)

## Testing

- Unit tests for `NotificationMailer` per event type
- Unit tests for preference checking logic
- Integration test: event → notifier → email job → mailer
- Test unsubscribe token generation + verification
- Test that email failures don't block in-app notifications
- Test preference defaults for new users

## Implementation Phases

1. **Phase 1:** `NotificationMailer` + send emails on events (all users, no preferences yet)
2. **Phase 2:** User preferences migration + settings UI + preference checking
3. **Phase 3:** Unsubscribe mechanism + email template polish
