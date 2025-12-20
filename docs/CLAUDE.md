# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the FeedbackBin marketing website.

## Project Overview

This is a Jekyll static site that serves as a simple marketing landing page for FeedbackBin (feedbackbin.com). The main FeedbackBin Rails application is located in the parent directory.

## Development Commands

### Setup and Development
- `bundle install` - Install Ruby gem dependencies
- `bundle exec jekyll serve` - Start development server (http://localhost:4000)
- `bundle exec jekyll serve --livereload` - Start with live reload
- `bundle exec jekyll build` - Build static site for production
- `bundle exec jekyll clean` - Clean generated site files

## Site Structure

```
docs/
├── _config.yml          # Jekyll configuration
├── _includes/           # Reusable HTML partials
│   ├── footer.html
│   ├── head.html
│   └── header.html
├── _layouts/            # Page templates
│   ├── default.html     # Main layout
│   └── page.html        # Layout for content pages (legal)
├── assets/
│   ├── css/style.scss   # All styles (mist color palette)
│   └── images/          # Logo and screenshots
├── index.md             # Landing page
├── privacy.md           # Privacy policy
├── terms.md             # Terms of service
└── 404.html             # Error page
```

## Styling

- **No Tailwind CSS** - Pure CSS with custom properties
- **Mist color palette** - Cool gray tones with subtle blue undertones
- **Dark mode** - Automatic via `prefers-color-scheme: dark`
- **Font** - Inter (loaded from Google Fonts)
- **Design inspiration** - Minimal, clean aesthetic inspired by modern SaaS landing pages

### Key CSS Classes
- `.container` - Max-width wrapper with padding
- `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-lg` - Button styles
- `.hero`, `.hero-content`, `.hero-subtitle` - Hero section
- `.features-grid`, `.feature` - Feature cards
- `.value-props`, `.value-prop` - Value proposition cards
- `.section-header` - Centered section titles
- `.badge` - Announcement badge/pill

## Content Guidelines

- Keep copy concise and benefit-focused
- Use the existing section structure (Hero → Features → Why → CTA)
- Legal pages use the `page` layout with `.page-content` styling

## Plugins

- `jekyll-feed` - RSS/Atom feed
- `jekyll-seo-tag` - SEO metadata (add front matter: title, description)
- `jekyll-sitemap` - XML sitemap generation

## Deployment

- Configured for GitHub Pages
- Built files go to `_site/` (gitignored)
- Use relative paths for assets

