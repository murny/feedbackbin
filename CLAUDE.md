# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup and Development
- `bin/setup` - Sets up the project and runs `bin/dev` by default
- `bin/setup --skip-server` - Sets up the project without starting the server
- `bin/dev` - Starts the development server using foreman (port 3000 by default)
- `bin/rails server` - Starts Rails server directly
- `bin/jobs` - Starts background job worker

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
- **Organization**: Multi-tenant structure where users belong to organizations
- **Post**: Feedback items created by users within organizations
- **Comment**: Threaded discussions on feedback posts
- **Category**: Organization of feedback into logical groups
- **PostStatus**: Status tracking for feedback lifecycle
- **Membership**: User-organization relationships with role-based permissions

### Key Rails Features Used
- **Hotwire/Turbo**: SPA-like interactions without JavaScript frameworks
- **Stimulus.js**: Minimal JavaScript controllers for enhanced interactions
- **ActiveStorage**: File uploads (avatars, logos)
- **ActionText**: Rich text content for posts and comments
- **Solid Queue**: Background job processing
- **Solid Cache**: Application caching
- **Solid Cable**: WebSocket connections
- **SQLite**: Primary database for all environments

### Authentication & Authorization
- Custom authentication system using `has_secure_password` via Rails
- OAuth integration (Google, Facebook) via Omniauth
- Session-based authentication stored in database
- Pundit policies for authorization (`app/policies/`)
- Role-based access via `Membership` model

### UI Framework
- **Tailwind CSS**: Utility-first styling with custom components
- **Basecoat CSS**: Shadcn-inspired layer on top of Tailwind
- **Custom UI Components**: Shadcn-inspired components in `app/components/elements/`
- **Lucide Icons**: Icon system via lucide-rails gem using `lucide_icon("example_icon")` view helper
- **Mobile-first responsive design**
- **Dark/light theme support**

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
- Authorization via Pundit policies

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

### Styling Guidelines
- Use Tailwind's built-in CSS variables: `bg-primary`, `text-primary-foreground`
- Follow mobile-first responsive approach
- Ensure components work in both light and dark themes
- Use semantic HTML elements and proper ARIA attributes

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
  posts:
    index:
      title: Posts
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

/file:.claude-swarm/context.md
