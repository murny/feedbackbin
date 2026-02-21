# Merge Duplicate Ideas

**Labels:** `feature`, `ideas`, `admin-tools`

## Summary

Add the ability for admins to merge duplicate ideas, consolidating votes, comments, watchers, and tags into a single canonical idea. This is a core feature in all competitors (Canny, Frill, Nolt) and is essential for keeping feedback boards clean as they grow.

Currently, when duplicate ideas appear, admins must ask users to re-vote on the "right" one and manually delete the duplicate — losing all its votes, comments, and discussion in the process.

## Motivation

- Duplicate ideas fragment votes, making it hard to gauge true demand
- Deleting duplicates loses valuable comments and discussion
- Users get frustrated when told to "go vote on the other one"
- All three competitors offer one-click merging with full data transfer

## Requirements

### 1. Merge Operation

When merging idea A (source) into idea B (target):

| Data | Behavior |
|---|---|
| **Comments** | Move all comments from A to B (re-parent to B) |
| **Votes** | Transfer votes from A to B. Skip voters who already voted on B. Recalculate `votes_count` on both. |
| **Watchers** | Transfer watch records from A to B. Skip users already watching B. |
| **Tags** | Add A's tags to B where B doesn't already have them. |
| **System comment** | Create on B: "Merged **A's Title** into this idea (X votes, Y comments, Z watchers transferred)" |
| **Event** | Create `idea_merged` event on B for audit trail |
| **Source idea** | Set `merged_into_id = B.id` (soft-delete, not hard-delete) |

### 2. Database Migration

```ruby
add_column :ideas, :merged_into_id, :integer
add_index :ideas, :merged_into_id
```

### 3. Model Changes

Add `Idea::Mergeable` concern with:

- `belongs_to :merged_into, class_name: "Idea", optional: true`
- `has_many :merged_ideas, class_name: "Idea", foreign_key: :merged_into_id`
- `scope :not_merged, -> { where(merged_into_id: nil) }`
- `merged?` — returns true if `merged_into_id` is present
- `merge_into!(target, merger:)` — executes the full merge in a transaction

All existing idea queries must add `.not_merged` to exclude merged ideas:
- Ideas index page
- Search results
- Roadmap view
- Board idea counts
- API/JSON responses

### 4. Controller & Routes

```ruby
# Nested under ideas
resource :merge, only: [:new, :create], module: :ideas
```

- `GET /ideas/:idea_id/merge/new` — merge dialog with searchable idea selector
- `POST /ideas/:idea_id/merge` — execute merge (params: `target_idea_id`)
- **Authorization:** admin or owner only

### 5. Merge UI

**Trigger:** "Merge into another idea..." option in the admin action menu on idea show page.

**Dialog:**
- Searchable idea selector (filter by title, exclude current idea and already-merged ideas)
- Preview showing: "Merge **Source Title** into **Target Title** — X votes, Y comments, Z watchers will be transferred"
- Confirm / Cancel buttons

**Post-merge:**
- Redirect to target idea with flash notice
- Source idea URL returns 302 redirect to target
- Source idea hidden from all listings and search

### 6. Edge Cases

- **Self-merge:** Prevent — validate source != target
- **Already-merged source:** Prevent — validate source is not already merged
- **Merge chains:** If A→B and B→C, visiting A should redirect to C (resolve to final target)
- **Cross-board merge:** Allowed — target's board is kept, source's board is irrelevant after merge
- **Counter caches:** Reset `votes_count` and `comments_count` on both source and target after transfer

## Out of Scope (v1)

- Undo / unmerge (merge is permanent, admin-only)
- Automatic duplicate detection / AI suggestions
- Bulk merge (multiple sources at once)
- Merge history page (system comment provides audit trail)

## Technical Notes

- Use a database transaction for the entire merge operation
- The existing `Idea::Eventable` concern and `SystemCommenter` can be extended for merge events
- Search records (FTS) should be updated/deleted for merged ideas
- Turbo Streams should broadcast updates to the target idea after merge

## Testing

- Unit tests for `Idea::Mergeable` (vote, comment, watcher, tag transfer)
- Test counter cache recalculation
- Test redirect behavior for merged idea URLs
- Test merged ideas excluded from all listings and search
- Test merge chain resolution (A→B→C)
- Test authorization (admin-only)
- Controller tests (success, validation errors, edge cases)
- System test for merge UI flow (search, select, confirm, redirect)

## Implementation Phases

1. **Phase 1:** Migration + `Idea::Mergeable` concern + merge logic with tests
2. **Phase 2:** Controller + routes + merge dialog UI
3. **Phase 3:** Redirect handling + exclude merged from listings + search cleanup
