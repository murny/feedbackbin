---
phase: 01-foundations-safety-net
reviewed_at: 2026-05-06
depth: standard
files_reviewed: 28
status: issues_found
findings:
  critical: 0
  warning: 5
  info: 10
  total: 15
---

# Phase 01: Code Review Report

**Reviewed:** 2026-05-06
**Depth:** standard
**Files Reviewed:** 28
**Status:** issues_found

## Summary

Phase 01 implementation is generally clean and follows project conventions (no DB-level FKs, model-layer integrity, scoped associations). Five warning-level findings worth resolving before merging — the most actionable being a hardcoded English string in the ideas index, a stale-association bug on `Account#reactivate`, and an asymmetric bang/non-bang pair in `Cancellable`. Ten info-level style/follow-up notes.

---

## Warnings

### WR-01: Hardcoded user-facing text violates project I18n rule

**File:** `app/views/ideas/index.html.erb:131-134`
**Issue:** Project rule (CLAUDE.md): "Always use Rails I18n; do not hardcode text in views." The empty-boards `else` branch hardcodes "We're not collecting ideas yet" and "An admin needs to finish setting up boards before ideas can be submitted." while the `if` branch above correctly uses `t(".empty_idea_title")`. Non-English locales will show English here.
**Fix:**
```erb
<h3 class="margin-block-start txt-x-large font-weight-bold"><%= t(".no_boards_title") %></h3>
<p class="margin-block-start-half txt-small txt-subtle" style="max-inline-size: 28rem;">
  <%= t(".no_boards_description") %>
</p>
```
Add to `config/locales/en.yml` under `ideas.index`.

### WR-02: `Account::Cancellable#reactivate` returns stale `cancelled?` state

**File:** `app/models/account/cancellable.rb:23-31`
**Issue:** After `cancellation.destroy`, the cached `has_one :cancellation` association still references the destroyed record on the in-memory account. `account.reactivate; account.cancelled?` returns `true` until reload. The model test works around this by calling `@account.reload`, but production callers will hit it. Asymmetric with `#cancel`, where `create_cancellation!` updates the parent's association cache.
**Fix:**
```ruby
def reactivate
  with_lock do
    if cancelled?
      run_callbacks :reactivate do
        cancellation.destroy!
        association(:cancellation).reset
      end
    end
  end
end
```

### WR-03: `reactivate` swallows destroy failures while `cancel` raises

**File:** `app/models/account/cancellable.rb:13-31`
**Issue:** `#cancel` uses `create_cancellation!` (raises on failure); `#reactivate` uses `cancellation.destroy` (returns false silently). A `before_destroy :abort` or DB error in reactivate fails silently and leaves the account marked cancelled.
**Fix:** Use `cancellation.destroy!` (covered by WR-02 patch).

### WR-04: `Cancellable#cancellable?` couples to signup gating

**File:** `app/models/account/cancellable.rb:37-39`
**Issue:** `cancellable?` returns `Account.accepting_signups?`, which is `multi_tenant || Account.none?`. In single-tenant mode (default for self-hosted), once any account exists the existing account becomes uncancellable. The semantic linkage between "the app is open to new signups" and "this account can self-cancel" is non-obvious. Either intentional and undocumented, or wrong.
**Fix:** Either rename (`cancellable_via_signup_flow?`) and add a comment explaining the gating, or decouple cancellation from signup state.

### WR-05: OmniAuth provider registration asymmetric with helper

**File:** `config/initializers/omniauth.rb:8-14`
**Issue:** In test env, Google and Facebook providers are registered unconditionally via `Rails.env.test? || (creds…)` short-circuits, but `OauthHelper#omniauth_provider_available?` does not have the test-env carve-out. Result: `/auth/google` is a live endpoint in test, but the sign-in partial hides the button unless test credentials are present. Carve-out is also undocumented; the registration uses `nil, nil` as client id/secret in test, which `omniauth-google_oauth2` may reject lazily.
**Fix:** Either align the helper with the initializer's test carve-out, or align the initializer with the helper (and have `test_helper.rb` set fake credentials before boot). At minimum, add a comment in the initializer explaining the test-env behavior.

---

## Info

### IN-01: Stale TODO comment in production view

**File:** `app/views/ideas/index.html.erb:14`
**Issue:** TODO comment in shipping view (`<%# TODO: The default title/description should be configurable for the account %>`). Tracker-only or remove.

### IN-02: Skip-only test has no value

**File:** `test/mailers/application_mailer_test.rb:10-13`
**Issue:** Second test only calls `skip` with a comment-like message. Pollutes suite output without coverage. Delete or replace with a real boot-isolated integration test.

### IN-03: `Account#importing?` is a literal stub

**File:** `app/models/account.rb:57-59`
**Issue:** `def importing?; false; end` always returns `false`, making `&& !importing?` in `active?` dead code. Add a comment that it's a placeholder for future import semantics, or remove the conjunction until import is implemented.

### IN-04: `db/seeds.rb` includes `TimeHelpers` into `main`

**File:** `db/seeds.rb:3-4`
**Issue:** Top-level `include ActiveSupport::Testing::TimeHelpers` pollutes `Object` with `travel`, `travel_back`, etc. Mostly harmless for seed-time, but has bitten Rails apps with autoloading edge cases. Optional: wrap seed body in `Module.new.module_eval`.

### IN-05: Seed file's `tap`-chains nest deeply

**File:** `db/seeds/feedbackbin.rb:14-53`
**Issue:** Triple-nested `.tap do |idea| .tap do |comment| … end end end` is hard to edit. Style only. Optional helper extraction.

### IN-06: Smoke test relies on brittle CSS selector

**File:** `test/system/smoke_test.rb:39-43`
**Issue:** `within(".vote") { first("button").click }` couples the test to button order. If a downvote/share button is later added inside `.vote`, the test silently clicks the wrong control.
**Fix:** Add `data-testid="upvote"` (or aria-label) on the upvote button; select on that.

### IN-07: Migration follows no-DB-FK convention (confirmation)

**File:** `db/migrate/20260420140000_create_account_cancellations.rb`
**Issue:** Convention honored. No fix required.

### IN-08: `Account::Cancellation` lacks a model-layer uniqueness validation

**File:** `app/models/account/cancellation.rb:3-6`
**Issue:** Unique index on `account_id` exists at the DB; no model validation mirrors it. `Cancellable#cancel` uses `with_lock`, but a direct `Account::Cancellation.create!` from elsewhere would rely solely on the DB index.
**Fix:**
```ruby
validates :account_id, uniqueness: true
```

### IN-09: `application_mailer.rb` reads ENV at class-load time

**File:** `app/mailers/application_mailer.rb:4`
**Issue:** `default from: ENV.fetch(...)` is evaluated once at class load — restart required to pick up changes. Worth a one-line comment in the file rather than a skipped test (see IN-02).

### IN-10: `omniauth_provider_available?` recomputes credentials on every call

**File:** `app/helpers/oauth_helper.rb:4-17`
**Issue:** Cosmetic; `Rails.application.credentials` is cached. No fix required.

---

## Files Reviewed (28)

- app/helpers/oauth_helper.rb
- app/mailers/application_mailer.rb
- app/models/account.rb
- app/models/account/cancellable.rb
- app/models/account/cancellation.rb
- app/views/application/_oauth_providers.html.erb
- app/views/ideas/index.html.erb
- config/initializers/omniauth.rb
- db/migrate/20260420140000_create_account_cancellations.rb
- db/schema.rb
- db/seeds.rb
- db/seeds/acme.rb
- db/seeds/feedbackbin.rb
- test/controllers/concerns/sortable_test.rb
- test/fixtures/account/cancellations.yml
- test/fixtures/accounts.yml
- test/fixtures/boards.yml
- test/fixtures/comments.yml
- test/fixtures/ideas.yml
- test/fixtures/votes.yml
- test/mailers/application_mailer_test.rb
- test/models/account/cancellable_test.rb
- test/models/board_test.rb
- test/models/comment_test.rb
- test/models/concerns/model_sortable_test.rb
- test/models/idea_test.rb
- test/models/vote_test.rb
- test/support/system_test_helper.rb
- test/system/smoke_test.rb
