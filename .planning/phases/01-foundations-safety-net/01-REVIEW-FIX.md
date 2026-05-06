---
phase: 01-foundations-safety-net
fix_scope: critical_warning
findings_in_scope: 5
fixed: 4
skipped: 1
status: partial
iteration: 1
---

# Phase 01: Code Review Fix Report

**Fixed at:** 2026-05-06
**Source review:** `.planning/phases/01-foundations-safety-net/01-REVIEW.md`
**Iteration:** 1

**Summary:**
- Findings in scope: 5 (5 Warnings, 0 Critical)
- Fixed: 4
- Skipped: 1
- Bonus fixes (out-of-REVIEW scope): 2

## Fixed Issues

### WR-01: Hardcoded user-facing text violates project I18n rule

**Files modified:** `app/views/ideas/index.html.erb`, `config/locales/en.yml`
**Commit:** `8f17045`
**Applied fix:** Added `ideas.index.no_boards_title` and `ideas.index.no_boards_description` translation keys to `en.yml`, then replaced the two hardcoded English strings in the empty-boards `else` branch (lines 131-134) with `t(".no_boards_title")` and `t(".no_boards_description")`.
**Verification:** `bin/i18n-tasks health` (all green, no missing/unused keys).

### WR-02: `Account::Cancellable#reactivate` returns stale `cancelled?` state

**Files modified:** `app/models/account/cancellable.rb`
**Commit:** `441ba27`
**Applied fix:** Replaced `cancellation.destroy` with `cancellation.destroy!` and added `association(:cancellation).reset` so the in-memory `has_one :cancellation` cache is cleared after the destroy. This also fixes WR-03 in the same patch as the reviewer indicated.
**Verification:** `bin/rubocop app/models/account/cancellable.rb` (clean), `bin/rails test test/models/account/cancellable_test.rb` (6 runs, 24 assertions, 0 failures).

### WR-03: `reactivate` swallows destroy failures while `cancel` raises

**Files modified:** `app/models/account/cancellable.rb`
**Commit:** `441ba27` (same commit as WR-02; reviewer noted "covered by WR-02 patch")
**Applied fix:** `cancellation.destroy!` now raises on `before_destroy :abort` or DB errors, matching the symmetric `create_cancellation!` behavior in `#cancel`.
**Verification:** Same as WR-02.

### WR-05: OmniAuth provider registration asymmetric with helper

**Files modified:** `app/helpers/oauth_helper.rb`, `config/initializers/omniauth.rb`
**Commit:** `d85c596`
**Applied fix:** Aligned `OauthHelper#omniauth_provider_available?` with the initializer's `Rails.env.test? || (creds…)` short-circuit so the sign-in partial reflects routes that actually exist in the test environment. Added a comment in the initializer documenting why providers register with `nil` credentials in test (so `OmniAuth.config.test_mode` stubs can short-circuit the callback chain).
**Verification:** `bin/rubocop app/helpers/oauth_helper.rb config/initializers/omniauth.rb` (clean), `bin/rails test` (958 runs, 2516 assertions, 0 failures, 1 pre-existing skip).

## Skipped Issues

### WR-04: `Cancellable#cancellable?` couples to signup gating

**File:** `app/models/account/cancellable.rb:37-39`
**Reason:** Skipped — fix requires product judgment outside the reviewer's scope. Both options offered carry behavior-change risk:

1. **Rename to `cancellable_via_signup_flow?`** is mostly safe at the call site (only one internal caller in the same concern) but does not change the underlying coupling and may further obscure intent without a satisfactory comment.
2. **Decoupling cancellation from signup state** is a product/policy decision (e.g. whether single-tenant accounts should ever be self-cancellable once seeded) that the review explicitly flags as "intentional and undocumented, or wrong" — the fixer should not unilaterally choose between those two positions.

A follow-up should determine the intended self-hosted single-tenant cancellation policy, then either rename or rewrite the predicate. Recording this for product review rather than guessing.

**Original issue:** `cancellable?` returns `Account.accepting_signups?`, which is `multi_tenant || Account.none?`. In single-tenant mode (default for self-hosted), once any account exists the existing account becomes uncancellable. The semantic linkage between "the app is open to new signups" and "this account can self-cancel" is non-obvious.

## Bonus Fixes (Out of REVIEW.md Scope)

These were flagged in the project_notes for the orchestrator and confirmed broken at runtime. Each was committed under a non-`WR-*` `fix(01)` message and is documented here for traceability.

### sign_up_path typo in comments form

**Files modified:** `app/views/comments/_form.html.erb`
**Commit:** `9f2e247`
**Applied fix:** `sign_up_path` does not exist in the route table; the user-registration route is `users_sign_up_path` (the bare `signup_path` is the account-creation flow). Replaced on line 27.
**Verification:** `bin/rails routes | grep sign_up` confirmed `users_sign_up_path` is the user-registration helper. `bin/erb_lint` clean. Full suite green (958 runs).

### Bare `pagy` in changelogs index

**Files modified:** `app/views/changelogs/index.html.erb`
**Commit:** `f07566a`
**Applied fix:** `ChangelogsController#index` assigns `@pagy`, but the view used bare `pagy.info_tag` / `pagy.series_nav` (which would resolve to the `pagy` *helper method*, not the instance). Replaced with `@pagy` on lines 38-39.
**Verification:** `bin/erb_lint` clean. Full suite green (958 runs).

---

_Fixed: 2026-05-06_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
