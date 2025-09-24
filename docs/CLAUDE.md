# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with the FeedbackBin marketing website and documentation site.

## Project Overview

This is a Jekyll 4.4.1 static site that serves as:
- **Marketing website** for FeedbackBin (feedbackbin.com) - features, pricing, help, etc.
- **Documentation hub** (feedbackbin.com/docs) - user guides, best practices, getting started
- **API documentation** (feedbackbin.com/docs/api) - technical API reference

The main FeedbackBin Rails application is located in the parent directory and runs at `app.feedbackbin.com`.

## Development Commands

### Setup and Development
- `bundle install` - Install Ruby gem dependencies
- `bundle exec jekyll serve` - Start development server (typically http://localhost:4000)
- `bundle exec jekyll serve --livereload` - Start with live reload for development
- `bundle exec jekyll build` - Build static site for production

### Content Management
- `bundle exec jekyll new-post "Title"` - Create new blog post (if using posts)
- `bundle exec jekyll clean` - Clean generated site files

## Site Structure

### Collections
- `_docs/` - Documentation pages (accessible at /docs/)
- `_guides/` - User guides and tutorials (accessible at /guides/)
- `_posts/` - Blog posts or announcements

### Key Files
- `_config.yml` - Jekyll configuration and site settings
- `index.md` - Homepage content
- `about.md` - About page
- `404.html` - Custom 404 error page
- `assets/` - CSS, JavaScript, and image assets

### Navigation
Configured in `_config.yml` under `header_pages`:
- Documentation index: `docs/index.md`
- Guides index: `guides/index.md`
- About page: `about.md`

## Content Guidelines

### Documentation Structure
- **Introduction docs**: Getting started, overview, basic concepts
- **User guides**: Step-by-step tutorials and best practices
- **API documentation**: Technical reference (consider /docs/api/ structure)
- **Help/Support**: FAQ, troubleshooting, contact information

### Marketing Content
- **Features**: Detailed feature explanations with benefits
- **Pricing**: Plans, pricing tiers, feature comparisons
- **Use cases**: Industry-specific applications and examples
- **Testimonials**: Customer stories and case studies

### Content Best Practices
- Use clear, action-oriented headings
- Include code examples for technical content
- Add screenshots/diagrams for complex workflows
- Keep marketing copy benefit-focused, not feature-focused
- Ensure mobile-responsive design considerations

## Jekyll Configuration

### Layouts & Styling
- Using custom layouts (`_layouts/`) and includes (`_includes/`) with site-wide CSS in `assets/css/`
- No Jekyll theme is in use; styles are token-driven with light/dark support
- Custom styling should go in `assets/css/`

### Plugins
- `jekyll-feed` - RSS/Atom feed generation
- `jekyll-seo-tag` - SEO metadata and social media tags (add `{% seo %}` to head include)
- `jekyll-sitemap` - XML sitemap generation
- Additional plugins can be added to Gemfile under `:jekyll_plugins` group

### Collections Configuration
```yaml
collections:
  docs:
    output: true
    permalink: /:collection/:name/
  guides:
    output: true
    permalink: /guides/:name/
```

## Deployment Notes

- Site is configured for GitHub Pages deployment
- Built site files are generated in `_site/` directory
- Ensure all links use relative paths for proper GitHub Pages deployment
- Test locally before pushing to ensure builds work correctly

## SEO and Performance

- We use `jekyll-seo-tag` (SEO), `jekyll-sitemap` (sitemap.xml), and `jekyll-feed` (RSS). Meta tags, canonical URLs, Open Graph, and Twitter Cards are generated automatically—do not add them by hand.
- Ensure site-wide config in `_config.yml` is correct:
  - `url`, `baseurl`, `title`, `description`, `twitter_username`
  - Optional defaults to improve social previews:
    - `image`: default Open Graph image (e.g., `/assets/images/og-default.png`)
    - `logo`: site logo for structured data
- Authoring checklist (per page/post front matter):
  - Required: `title`, `description` (~50–160 chars)
  - Recommended: `image` (absolute or site-relative), `tags`
  - Example:
    ```yaml
    ---
    title: Collect better product feedback
    description: Learn how FeedbackBin helps teams centralize and prioritize feedback.
    image: /assets/images/og/collect-feedback.png
    tags: [docs, guides]
    ---
    ```
- Sitemaps: Generated automatically at `/sitemap.xml` (no manual action needed).
- Robots: Add a `robots.txt` if needed. Example:
  ```
  User-agent: *
  Allow: /

  Sitemap: https://feedbackbin.com/sitemap.xml
  ```
- Performance:
  - Optimize images (compress, prefer SVG when possible); use `loading="lazy"` on `<img>`.
  - Keep pages lean; avoid blocking scripts/styles. Reuse components and shared includes.
  - Use descriptive headings and semantic HTML for accessibility and rich snippets.

## Content Organization Tips

### For Documentation
- Start with a clear index page explaining the documentation structure
- Use consistent formatting and navigation
- Include search functionality if the documentation grows large
- Version API docs appropriately

### For Marketing
- Focus on user benefits over technical features
- Include clear calls-to-action
- Use social proof (testimonials, logos, metrics)
- Make pricing and signup flows obvious

## Development Notes

- Test site locally with `bundle exec jekyll serve` before deploying
- Use Jekyll's built-in Sass processing for CSS
- Leverage Jekyll's data files (`_data/`) for structured content like pricing tiers
- Consider using Jekyll's built-in syntax highlighting for code examples
