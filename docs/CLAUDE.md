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
│   └── images/          # Logo and screenshots (WebP preferred)
├── index.md             # Landing page
├── privacy.md           # Privacy policy
├── terms.md             # Terms of service
└── 404.html             # Error page
```

## Styling Guidelines

- **No Tailwind CSS** - Pure CSS with custom properties
- **Mist color palette** - Cool gray tones with subtle blue undertones
- **Dark mode** - Automatic via `prefers-color-scheme: dark`
- **Font** - Inter (loaded from Google Fonts)
- **Design inspiration** - Minimal, clean aesthetic inspired by modern SaaS landing pages
- **No inline styles** - Use CSS classes for all styling

### Key CSS Classes

#### Layout & Structure
- `.container` - Max-width wrapper with padding
- `.section-header` - Centered section titles

#### Components
- `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-lg` - Button styles
- `.badge` - Announcement badge/pill
- `.icon` - Utility class for SVG icons (1rem x 1rem)

#### Hero Section
- `.hero` - Hero section wrapper
- `.hero-content` - Hero content container
- `.hero-subtitle` - Hero subtitle text
- `.hero-cta` - CTA button container
- `.hero-screenshot` - Screenshot container

#### Features
- `.features-grid` - Feature card grid
- `.feature` - Individual feature card
- `.feature-icon` - Feature icon wrapper

#### Value Props & Other Sections
- `.value-props` - Value proposition grid
- `.value-prop` - Individual value prop card
- `.faq-layout` - FAQ section layout
- `.faq-list` - FAQ list container
- `.faq-item` - Individual FAQ item

#### Error Pages
- `.error-hero` - Error page hero (60vh min-height, flexbox centered)
- `.error-code` - Large error code display (e.g., "404")
- `.error-title` - Error page title

#### Legal Pages
- `.page-layout` - Page wrapper for legal pages
- `.page-content` - Content container for legal pages

## Image Optimization

- **Prefer WebP format** for screenshots and large images
- Keep PNG versions as fallbacks if needed
- Use `.webp` extensions in image paths for optimized images
- Logo files available in both SVG and PNG formats

## SEO & Front Matter

All pages should include proper front matter for jekyll-seo-tag:

```yaml
---
layout: default
title: "Page title (50-60 characters)"
description: "Page description (50-160 characters)"
image: /assets/images/feedbackbin-logo.png  # Optional but recommended
---
```

### SEO Best Practices
- Always include `title` and `description` in front matter
- Add `image` field for better social media previews
- Use the FeedbackBin logo for default image
- Keep descriptions between 50-160 characters
- Make titles concise and descriptive

## Content Guidelines

- Keep copy concise and benefit-focused
- Use the existing section structure (Hero → Features → Why → CTA)
- Legal pages use the `page` layout with `.page-content` styling
- Avoid inline styles - use CSS classes instead

## Plugins

- `jekyll-feed` - RSS/Atom feed
- `jekyll-seo-tag` - SEO metadata (requires title, description in front matter)
- `jekyll-sitemap` - XML sitemap generation

## Deployment

- Configured for GitHub Pages
- Built files go to `_site/` (gitignored)
- Use relative paths for assets
