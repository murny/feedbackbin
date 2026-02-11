# AGENTS.md

This file provides guidance to AI coding assistants when working with code in this repository.

## Development Commands

### Setup and Development
- `bin/setup` - Sets up the project (install deps, prepare database, clean logs)
- `bin/setup --reset` - Sets up the project and resets the database
- `bin/dev` - Starts the development server
- `bin/rails server` - Starts Rails server directly
- `bin/jobs` - Starts background job worker (when using Solid Queue seperately)

### Testing
- `bin/rails test` - Run all Rails tests
- `bin/rails test:system` - Run system tests only
- `env RAILS_ENV=test bin/rails db:seed:replant` - Test seed data

### Linting and Code Quality
- `bin/rubocop` - Check Ruby code style
- `bin/rubocop -a` - Auto-correct Ruby style offenses
- `bin/erb_lint --lint-all` - Check ERB templates
- `bin/erb_lint --lint-all -a` - Auto-correct ERB templates (use with caution)
- `bin/i18n-tasks health` - Check I18n file health
- `bin/i18n-tasks normalize` - Normalize I18n files

### Security Checks
- `bin/brakeman` - Static security analysis
- `bin/bundler-audit` - Gem vulnerability check
- `bin/importmap audit` - JavaScript vulnerability check

### Continuous Integration
- `bin/ci` - Run full CI pipeline (setup, linting, security, tests)

## Architecture Overview

FeedbackBin is a customer feedback management platform built with Ruby on Rails 8. The application follows standard Rails patterns with some key architectural decisions:

### Core Domain Models
- **User**: Authentication, profiles, and user management with OAuth support
- **Account**: Multi-tenant structure where users belong to accounts
- **Idea**: Feedback items created by users within accounts
- **Comment**: Threaded discussions on feedback ideas
- **Boards**: Organization of feedback ideas into logical groups
- **Status**: Status tracking for feedback ideas lifecycle

### Key Rails Features Used
- **Hotwire/Turbo**: SPA-like interactions without JavaScript frameworks
- **Stimulus.js**: Minimal JavaScript controllers for enhanced interactions
- **ActiveStorage**: File uploads (avatars, logos)
- **ActionText**: Rich text content for ideas and comments
- **Solid Queue**: Background job processing
- **Solid Cache**: Application caching
- **Solid Cable**: WebSocket connections
- **SQLite**: Primary database for all environments

### Authentication & Authorization
- Global Identity (email-based) can have Users in multiple Accounts
- Users belong to an Account and have roles: owner, admin, member, system, bot
- OAuth integration (Google, Facebook) via Omniauth
- Sessions managed via signed cookies
- Role-based access via `Role` model

### UI Framework
- **Vanilla CSS**: No Sass, no PostCSS, no Tailwind — pure modern CSS with native features
- **CSS Cascade Layers**: `@layer reset, base, components, modules, utilities` for specificity control
- **OKLCH Color System**: Perceptually uniform colors with P3 gamut support
- **Custom UI Components**: Shadcn-inspired ViewComponents in `app/components/elements/`
- **Lucide Icons**: Icon system via lucide-rails gem using `lucide_icon("example_icon")` view helper
- **Mobile-first responsive design**
- **Dark/light theme support** via CSS custom property redefinition

### Key Patterns and Conventions
- **Concerns**: Shared behavior in `app/models/concerns/` and `app/controllers/concerns/`
- **Current Context**: Thread-safe current user/organization via `Current` model
- **Form Builders**: Custom form builder in `app/helpers/form_builders/`
- **Broadcasting**: Real-time updates using Turbo Streams over WebSocket
- **Multi-tenancy**: Organization-scoped data access

### Controller Structure
- RESTful controllers following Rails conventions
- Authentication handled via `Authentication` concern
- Organization context set via `SetCurrentOrganization` concern
- Authorization via role-based guards (`ensure_admin`, `ensure_owner`) in `Authorization` concern
- Resource-level permissions via `can_administer_*` and `can_change?` methods on `User::Role`

### Testing Strategy
- Rails testing framework (Rails + Minitest) with fixtures
- System tests using Capybara and Selenium (use sparingly, only in critical paths and at smoke test level)
- Comprehensive test coverage expected for all models/controllers
- Test data managed through `test/fixtures/`

### Deployment
- **Kamal**: Container-based deployment system
- **Docker**: Containerized application
- **Self-hosted**: Designed for self-hosted environments

## Development Notes

### Custom Components
The application uses custom UI components inspired by Shadcn UI, built with ViewComponent. Use ViewComponents instead of creating custom HTML/CSS.

Example button usage:
```erb
<%= render Elements::ButtonComponent.new(variant: :outline, size: :default) do %>
  <%= lucide_icon "plus" %>
  Click me
<% end %>
```

Example badge usage:
```erb
<%= render Elements::BadgeComponent.new(variant: :secondary) do %>
  <%= lucide_icon "check" %>
  Success
<% end %>
```

### Code Comments
- Do not add comments that explain the context of a change or the prompt that led to it
- Comments should be useful to future readers who have no knowledge of why a change was made
- Bad: `<%# Replies are always from regular users - system comments are only top-level %>` (explains prompt context, not the code)
- Good: Only add comments when the code itself is complex and requires explanation

### CSS Architecture

**No preprocessors, no utility frameworks.** The entire CSS codebase is vanilla CSS using modern browser features.

#### Cascade Layers

All CSS must be placed in the appropriate `@layer`. The layer order defines specificity priority (last wins):

```css
@layer reset, base, components, modules, utilities;
```

| Layer | Purpose | Example |
|-------|---------|---------|
| `reset` | Normalize browser defaults | `* { margin: 0 }` |
| `base` | Global element styles | `body`, `a`, `kbd` |
| `components` | Reusable UI patterns | `.btn`, `.card`, `.input` |
| `modules` | Page/feature-specific styles | `.ideas-list`, `.settings-form` |
| `utilities` | Single-purpose helpers (highest priority) | `.flex`, `.txt-small`, `.visually-hidden` |

Never use `!important` — layers handle specificity conflicts.

#### OKLCH Color System

Colors are defined as OKLCH components in `_global.css` and consumed via `oklch()`:

```css
:root {
  --lch-blue-dark: 57.02% 0.1895 260.46;
  --color-link: oklch(var(--lch-blue-dark));
}
```

Dark mode works by redefining the OKLCH variable values — components automatically adapt:

```css
html[data-theme="dark"] {
  --lch-ink-darkest: 96.02% 0.0034 260;  /* flipped from dark to light */
  --lch-canvas: 20% 0.0195 232.58;        /* flipped from light to dark */
}
```

Always use existing color tokens (`--color-ink`, `--color-canvas`, `--color-link`, etc.) rather than raw color values.

#### Component Pattern

Components use BEM-inspired naming with CSS custom properties as their API:

```css
@layer components {
  .btn {
    /* Component API — these are the knobs modifiers turn */
    --btn-background: var(--color-canvas);
    --btn-color: var(--color-ink);
    --btn-padding: 0.5em 1.1em;

    background-color: var(--btn-background);
    color: var(--btn-color);
    padding: var(--btn-padding);
  }

  /* Modifiers only override variables */
  .btn--link {
    --btn-background: var(--color-link);
    --btn-color: var(--color-ink-inverted);
  }
}
```

Naming rules:
- `.block` — the component (`.card`, `.btn`, `.input`)
- `.block__element` — a child part (`.card__header`, `.card__title`)
- `.block--modifier` — a variant (`.btn--link`, `.card--notification`)
- Keep elements flat — never `.card__header__title`, always `.card__title`

#### Native CSS Nesting

Use native CSS nesting (no preprocessor needed):

```css
.btn {
  background: var(--btn-background);

  &:hover { filter: brightness(var(--btn-hover-brightness)); }
  &[disabled] { opacity: 0.3; cursor: not-allowed; }

  html[data-theme="dark"] & {
    --btn-hover-brightness: 1.25;
  }
}
```

#### Modern CSS Features

Use these freely — they are part of the architecture:

- **`:has()` selectors** for parent-aware styling: `.card:has(.card__closed) { }`
- **`:where()` selectors** for zero-specificity defaults (easy to override): `.btn:where(:focus-visible) { }`
- **`:is()` selectors** for grouping: `.btn :is(input[type=radio], input[type=checkbox]) { }`
- **`color-mix()`** for dynamic colors: `color-mix(in srgb, var(--card-color) 4%, var(--color-canvas))`
- **`@starting-style`** for entry animations on `<dialog>` and popovers
- **Logical properties** throughout: `padding-inline`, `margin-block-start`, `inline-size` (not `width`/`padding-left`)
- **Variable fallbacks**: `var(--btn-icon-size, 1.3em)` for sensible defaults
- **Container queries** where appropriate
- **`field-sizing: content`** for auto-sizing textareas (behind `@supports`)

#### Utility Classes (Minimal)

~60 focused utility classes in `utilities.css` for layout and text. Use them in markup for simple layout needs:

```html
<div class="flex gap">
  <span class="txt-small txt-subtle">Posted 2 days ago</span>
</div>
```

Do NOT create Tailwind-style utility classes. If you need more than 2-3 utilities on an element, create a component class instead.

#### File Organization

One CSS file per concern, ~100-300 lines each:

```
app/assets/stylesheets/
├── _global.css          # CSS variables, layers, OKLCH tokens, dark mode
├── reset.css            # Modern CSS reset
├── base.css             # Element defaults
├── layout.css           # Grid layout
├── utilities.css        # Utility classes
├── buttons.css          # .btn component
├── cards.css            # .card component
├── inputs.css           # Form controls
├── dialog.css           # Dialog/modal animations
├── popup.css            # Dropdown menus
└── ...                  # One file per component/module
```

#### Key Principles

1. **No preprocessors** — native CSS is powerful enough
2. **No Tailwind** — utilities exist but are minimal and purposeful
3. **No CSS-in-JS** — styles live in stylesheets
4. **No `!important`** — cascade layers handle specificity
5. **Variables as component APIs** — modifiers override variables, not properties
6. **Dark mode via token redefinition** — components never need `html[data-theme="dark"]` overrides unless adjusting interaction behavior (e.g. hover brightness)
7. **Logical properties** — use `inline`/`block` not `left`/`right`/`top`/`bottom`
8. **Semantic HTML** — use proper elements and ARIA attributes

### View Guidelines
- Always use Rails I18n; do not hardcode text in views.
- Use scoped helpers like `t('.title')` and store strings in `config/locales/en.yml`.
- Run `bin/i18n-tasks health` regularly to keep translations consistent.

Example:
```erb
<h1><%= t('.title') %></h1>
```

```yml
en:
  ideas:
    index:
      title: Ideas
```

### Turbo/Hotwire Usage
- Prefer server-side rendering over client-side JavaScript
- Use Turbo Streams for dynamic updates
- Use Turbo Frames for partial page updates
- Real-time features via Turbo Streams over WebSocket

### Database Migrations
Database schema is managed through standard Rails migrations in `db/migrate/`. The application uses multiple SQLite databases:
- Main database: Application data
- Cache database: Application cache
- Queue database: Background jobs
- Cable database: WebSocket connections
