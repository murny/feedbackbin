# FeedbackBin Marketing Site

This is the marketing website for FeedbackBin, built with Jekyll. The site is a simple, fast static site showcasing FeedbackBin's features and benefits.

## Prerequisites

- Ruby 2.7 or higher
- Bundler (`gem install bundler`)

## Quick Start

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Run the development server**
   ```bash
   bundle exec jekyll serve
   ```

3. **View the site**

   Open your browser to [http://localhost:4000](http://localhost:4000)

## Development

### Live Reload

For automatic browser refresh on file changes:

```bash
bundle exec jekyll serve --livereload
```

### Build for Production

Generate the static site files:

```bash
bundle exec jekyll build
```

The built site will be in the `_site/` directory.

### Clean Build Files

Remove generated files:

```bash
bundle exec jekyll clean
```

## Project Structure

```
docs/
├── _config.yml          # Jekyll configuration
├── _includes/           # Reusable HTML partials
│   ├── footer.html
│   ├── head.html
│   └── header.html
├── _layouts/            # Page templates
│   ├── default.html     # Main layout
│   └── page.html        # Content pages layout
├── assets/
│   ├── css/
│   │   └── style.scss   # All site styles
│   └── images/          # Logos and screenshots
├── index.md             # Homepage
├── privacy.md           # Privacy policy
├── terms.md             # Terms of service
└── 404.html             # Error page
```

## Styling

The site uses a custom vanilla CSS framework (no Tailwind or Bootstrap) with:

- **Mist color palette** - Cool gray tones with subtle blue undertones
- **Automatic dark mode** - Switches based on system preferences
- **Inter font** - Clean, modern typography
- **Responsive design** - Mobile-first approach

## Deployment

The site is configured for GitHub Pages and can be deployed by pushing to the main branch. The build process is handled automatically by GitHub.

## Main Application

This is just the marketing site. The main FeedbackBin Rails application is located in the parent directory (`../`).
