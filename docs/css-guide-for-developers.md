# CSS Guide: Learning Fizzy-Style CSS

A beginner-friendly guide to understanding modern CSS patterns used in Fizzy (and soon, FeedbackBin).

---

## Table of Contents

1. [The Big Picture: Why Change?](#the-big-picture-why-change)
2. [BEM Naming Convention](#bem-naming-convention)
3. [CSS Custom Properties (Variables)](#css-custom-properties-variables)
4. [CSS Layers](#css-layers)
5. [Logical Properties](#logical-properties)
6. [Modern CSS Selectors](#modern-css-selectors)
7. [Component Architecture](#component-architecture)
8. [Dark Mode the Smart Way](#dark-mode-the-smart-way)
9. [Putting It All Together](#putting-it-all-together)

---

## The Big Picture: Why Change?

### Tailwind Approach (Current)
```erb
<%# In your ERB template %>
<button class="inline-flex items-center justify-center px-4 py-2 bg-blue-600
               text-white font-semibold rounded-full border border-transparent
               hover:bg-blue-700 focus:outline-none focus:ring-2
               focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50">
  Click me
</button>
```

**Problems:**
- Classes are in the HTML, making templates hard to read
- Lots of repetition across components
- Hard to make consistent changes across the app
- Need special tools (TailwindMerge) to handle class conflicts

### Fizzy Approach (Target)
```erb
<%# In your ERB template %>
<button class="btn btn--link">Click me</button>
```

```css
/* In buttons.css */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 0.5em 1em;
  /* ... */
}

.btn--link {
  --btn-background: var(--color-link);
  --btn-color: var(--color-ink-inverted);
}
```

**Benefits:**
- Clean, readable HTML
- Change styles in one place, affects everywhere
- No special tooling needed
- Easier to understand and maintain

---

## BEM Naming Convention

**BEM** stands for **Block, Element, Modifier**. It's a naming system that makes CSS classes predictable and organized.

### The Three Parts

```
.block                  → The main component (the "thing")
.block__element         → A part inside the component
.block--modifier        → A variation of the component
```

### Real Example: Card Component

Think of a card as a container with parts inside it:

```
┌─────────────────────────────┐
│ HEADER          [tag] [tag] │  ← .card__header
├─────────────────────────────┤
│                             │
│  Title goes here            │  ← .card__title
│  Description text...        │  ← .card__content
│                             │
├─────────────────────────────┤
│ Author info     Dec 15      │  ← .card__meta
└─────────────────────────────┘
        ↑
    .card (the block)
```

### In CSS (from Fizzy's cards.css):

```css
/* Block: The card itself */
.card {
  background-color: var(--card-bg-color);
  border-radius: var(--border-radius);
  display: flex;
  flex-direction: column;
  padding: var(--card-padding-block) var(--card-padding-inline);
}

/* Elements: Parts of the card (use double underscore __) */
.card__header {
  display: flex;
  align-items: center;
  gap: var(--card-header-space);
}

.card__title {
  font-size: var(--text-xx-large);
  font-weight: 900;
}

.card__body {
  display: flex;
  flex-grow: 1;
  gap: 1ch;
}

.card__meta {
  font-size: var(--text-x-small);
  text-transform: uppercase;
}

/* Modifier: A variation (use double dash --) */
.card--notification {
  --card-padding-inline: 1ch;
  --card-padding-block: 1ch;
  background-color: var(--color-canvas);
}
```

### In HTML:

```html
<article class="card">
  <header class="card__header">
    <span class="card__board">Feature Request</span>
  </header>
  <div class="card__body">
    <h2 class="card__title">Add dark mode</h2>
    <div class="card__content">
      It would be great to have a dark theme...
    </div>
  </div>
  <footer class="card__meta">
    Posted by Jane · 2 days ago
  </footer>
</article>

<!-- A notification variant -->
<article class="card card--notification">
  <!-- Same structure, different styling -->
</article>
```

### Quick Reference

| Pattern | Meaning | Example |
|---------|---------|---------|
| `.block` | The component | `.card`, `.btn`, `.nav` |
| `.block__element` | Part of component | `.card__header`, `.btn__icon` |
| `.block--modifier` | Variation | `.card--featured`, `.btn--large` |

### Common Mistakes to Avoid

```css
/* ❌ Don't nest elements in element names */
.card__header__title { }

/* ✅ Keep it flat - elements belong to the block */
.card__title { }

/* ❌ Don't chain modifiers */
.card--featured--large { }

/* ✅ Use separate modifier classes */
.card--featured { }
.card--large { }
```

---

## CSS Custom Properties (Variables)

CSS Custom Properties (also called CSS Variables) let you define reusable values. They're like variables in programming.

### Basic Syntax

```css
/* Define a variable (starts with --) */
:root {
  --color-primary: blue;
  --spacing-small: 0.5rem;
}

/* Use a variable with var() */
.button {
  background-color: var(--color-primary);
  padding: var(--spacing-small);
}
```

### Fizzy's Clever Pattern: Variables as Component API

This is the powerful part. Instead of creating many modifier classes with different properties, you create ONE base class that uses variables, then modifiers just change the variables:

```css
/* From Fizzy's buttons.css */
.btn {
  /* Define the "API" - these are the knobs you can turn */
  --btn-background: var(--color-canvas);
  --btn-color: var(--color-ink);
  --btn-border-color: var(--color-ink-light);
  --btn-border-radius: 99rem;
  --btn-padding: 0.5em 1.1em;

  /* Use those variables in the actual styles */
  background-color: var(--btn-background);
  color: var(--btn-color);
  border: 1px solid var(--btn-border-color);
  border-radius: var(--btn-border-radius);
  padding: var(--btn-padding);
}

/* Modifiers just override the variables! */
.btn--link {
  --btn-background: var(--color-link);
  --btn-color: var(--color-ink-inverted);
  --btn-border-color: var(--color-canvas);
}

.btn--negative {
  --btn-background: var(--color-negative);
  --btn-color: var(--color-ink-inverted);
  --btn-border-color: var(--color-negative);
}

.btn--plain {
  --btn-background: transparent;
  --btn-border-size: 0;
  --btn-padding: 0;
}
```

### Why This Is Better

**Old way (lots of repeated code):**
```css
.btn-primary {
  background-color: blue;
  color: white;
  border: 1px solid blue;
  padding: 0.5em 1em;
  border-radius: 4px;
  /* ...20 more properties */
}

.btn-danger {
  background-color: red;
  color: white;
  border: 1px solid red;
  padding: 0.5em 1em;      /* repeated! */
  border-radius: 4px;       /* repeated! */
  /* ...20 more properties repeated */
}
```

**Fizzy way (DRY - Don't Repeat Yourself):**
```css
.btn {
  /* All the structure defined once */
  background-color: var(--btn-background);
  color: var(--btn-color);
  /* ...all properties use variables */
}

.btn--primary {
  --btn-background: blue;  /* Only change what's different */
  --btn-color: white;
}

.btn--danger {
  --btn-background: red;
  --btn-color: white;
}
```

### Variable Fallbacks

You can provide default values:

```css
.btn {
  /* If --btn-icon-size isn't set, use 1.3em */
  --icon-size: var(--btn-icon-size, 1.3em);
}
```

---

## CSS Layers

CSS Layers (`@layer`) give you control over which styles "win" when there are conflicts.

### The Problem They Solve

Normally, CSS specificity determines which style wins. This can get confusing:

```css
/* Which color wins? Depends on specificity... */
.btn { color: blue; }
.card .btn { color: red; }
#submit-btn { color: green; }
.btn.btn--primary { color: purple; }
```

### The Solution: Explicit Layers

```css
/* Define layer order - last one wins */
@layer reset, base, components, utilities;

@layer reset {
  /* Styles here have lowest priority */
  * { margin: 0; padding: 0; }
}

@layer base {
  /* Basic element styles */
  button { cursor: pointer; }
}

@layer components {
  /* Component styles */
  .btn { background: blue; }
}

@layer utilities {
  /* Utility classes - highest priority, always win */
  .hidden { display: none !important; }
}
```

### Fizzy's Layer Structure

From `_global.css`:
```css
@layer reset, base, components, modules, utilities, native, platform;
```

| Layer | Purpose | Priority |
|-------|---------|----------|
| `reset` | Normalize browser defaults | Lowest |
| `base` | Basic element styles (a, button, etc.) | ↓ |
| `components` | Reusable components (.btn, .card) | ↓ |
| `modules` | Feature-specific styles | ↓ |
| `utilities` | Helper classes (.flex, .hidden) | ↓ |
| `native` | Native app styles | ↓ |
| `platform` | iOS/Android specific | Highest |

### Using Layers

```css
@layer components {
  .card {
    padding: 1rem;
    background: white;
  }

  .btn {
    padding: 0.5em 1em;
  }
}

@layer utilities {
  .p-0 { padding: 0; }  /* This will override .card padding if both are applied */
}
```

---

## Logical Properties

Logical properties make your CSS work correctly in all languages, including right-to-left (RTL) languages like Arabic and Hebrew.

### Physical vs Logical

**Physical properties** are tied to the screen:
- `left`, `right`, `top`, `bottom`
- `margin-left`, `padding-right`
- `width`, `height`

**Logical properties** are tied to content flow:
- `inline-start`, `inline-end` (horizontal in English)
- `block-start`, `block-end` (vertical in English)
- `inline-size`, `block-size`

### Visual Guide

```
English (LTR - Left to Right):

     block-start (top)
          ↓
    ┌─────────────────┐
    │                 │
inline-start →    ← inline-end
(left)               (right)
    │                 │
    └─────────────────┘
          ↑
     block-end (bottom)


Arabic (RTL - Right to Left):

     block-start (top)
          ↓
    ┌─────────────────┐
    │                 │
inline-end →      ← inline-start
(left)               (right)
    │                 │
    └─────────────────┘
          ↑
     block-end (bottom)
```

### Conversion Table

| Physical (old) | Logical (new) |
|----------------|---------------|
| `width` | `inline-size` |
| `height` | `block-size` |
| `margin-left` | `margin-inline-start` |
| `margin-right` | `margin-inline-end` |
| `padding-left` | `padding-inline-start` |
| `padding-right` | `padding-inline-end` |
| `margin-top` | `margin-block-start` |
| `margin-bottom` | `margin-block-end` |
| `left` | `inset-inline-start` |
| `right` | `inset-inline-end` |
| `top` | `inset-block-start` |
| `bottom` | `inset-block-end` |

### Shorthand Properties

```css
/* Horizontal padding (left + right) */
padding-inline: 1rem;

/* Vertical padding (top + bottom) */
padding-block: 0.5rem;

/* All insets at once */
inset: 0;  /* Same as top: 0; right: 0; bottom: 0; left: 0; */
```

### Real Example from Fizzy

```css
/* From cards.css */
.card__header {
  /* Instead of: margin-left: -1rem; margin-right: -0.5rem; */
  margin-inline: calc(-1 * var(--card-padding-inline)) calc(-0.5 * var(--card-padding-inline));

  /* Instead of: margin-top: calc(-1 * var(--card-padding-block)); */
  margin-block-start: calc(-1 * var(--card-padding-block));
}

.card__board {
  /* Instead of: padding-top: 0.25lh; padding-bottom: 0.25lh; */
  padding-block: 0.25lh;

  /* Instead of: padding-left: var(--card-padding-inline); padding-right: 1ch; */
  padding-inline: var(--card-padding-inline) 1ch;
}
```

---

## Modern CSS Selectors

Fizzy uses modern CSS features that make styling more powerful.

### Nesting (Native CSS)

You can nest selectors just like in Sass, but it's native CSS now:

```css
.btn {
  background: blue;

  /* Nested hover state - equivalent to .btn:hover */
  &:hover {
    background: darkblue;
  }

  /* Nested child - equivalent to .btn .icon */
  .icon {
    width: 1em;
  }

  /* Nested modifier - equivalent to .btn.btn--large */
  &.btn--large {
    padding: 1em 2em;
  }
}
```

### The :has() Selector

Select a parent based on what it contains:

```css
/* Style a button differently if it contains a checked input */
.btn:has(input:checked) {
  --btn-background: var(--color-ink);
  --btn-color: var(--color-ink-inverted);
}

/* Style a card differently if it has a "closed" stamp */
.card:has(.card__closed) {
  --card-color: var(--color-card-complete);
}
```

### The :where() Selector

Apply styles with zero specificity (easy to override):

```css
.btn {
  /* These can be easily overridden */
  &:where(:focus-visible) {
    outline: 2px solid var(--focus-ring-color);
  }

  &:where([disabled]) {
    opacity: 0.5;
    cursor: not-allowed;
  }
}
```

### The :is() Selector

Match any of several selectors:

```css
/* Instead of writing: */
.btn input[type=radio],
.btn input[type=checkbox] {
  appearance: none;
}

/* Write: */
.btn :is(input[type=radio], input[type=checkbox]) {
  appearance: none;
}
```

---

## Component Architecture

### File Organization

Each component gets its own file:

```
app/assets/stylesheets/
├── _global.css        # Variables, layers, tokens
├── reset.css          # Browser reset
├── base.css           # Element defaults
├── components/
│   ├── buttons.css    # .btn and variants
│   ├── cards.css      # .card and variants
│   ├── badges.css     # .badge and variants
│   └── inputs.css     # Form inputs
└── modules/
    ├── ideas.css      # Ideas feature styles
    └── comments.css   # Comments feature styles
```

### Component File Structure

Each component file follows a pattern:

```css
@layer components {
  /* ==========================================================================
     Button Component
     ========================================================================== */

  /* Base
  /* ------------------------------------------------------------------------ */

  .btn {
    /* Component variables (the API) */
    --btn-background: var(--color-canvas);
    --btn-color: var(--color-ink);
    --btn-padding: 0.5em 1em;

    /* Structure */
    display: inline-flex;
    align-items: center;
    justify-content: center;

    /* Appearance */
    background: var(--btn-background);
    color: var(--btn-color);
    padding: var(--btn-padding);

    /* Interactions */
    &:hover { }
    &:focus-visible { }
    &[disabled] { }
  }

  /* Variants
  /* ------------------------------------------------------------------------ */

  .btn--primary {
    --btn-background: var(--color-primary);
  }

  .btn--large {
    --btn-padding: 1em 2em;
  }

  /* States
  /* ------------------------------------------------------------------------ */

  .btn--loading {
    pointer-events: none;
  }
}
```

---

## Dark Mode the Smart Way

### The Problem with Naive Dark Mode

```css
/* ❌ Naive approach: duplicate everything */
.card {
  background: white;
  color: black;
}

.dark .card {
  background: #1a1a1a;
  color: white;
}

.btn {
  background: blue;
  color: white;
}

.dark .btn {
  background: lightblue;
  color: black;
}

/* This gets out of control fast! */
```

### Fizzy's Approach: Change Variables, Not Styles

```css
/* Define color variables for light mode */
:root {
  --lch-canvas: 100% 0 0;              /* white */
  --lch-ink-darkest: 26% 0.05 264;     /* near black */

  --color-canvas: oklch(var(--lch-canvas));
  --color-ink: oklch(var(--lch-ink-darkest));
}

/* Override ONLY the variables for dark mode */
html[data-theme="dark"] {
  --lch-canvas: 20% 0.0195 232.58;     /* dark blue-gray */
  --lch-ink-darkest: 96.02% 0.0034 260; /* near white */
}

/* Components use the variables - no dark mode code needed! */
.card {
  background: var(--color-canvas);
  color: var(--color-ink);
}

.btn {
  background: var(--color-canvas);
  color: var(--color-ink);
}
```

### System Preference Fallback

```css
/* If user hasn't chosen a theme, follow system preference */
@media (prefers-color-scheme: dark) {
  html:not([data-theme]) {
    --lch-canvas: 20% 0.0195 232.58;
    --lch-ink-darkest: 96.02% 0.0034 260;
    /* ... rest of dark mode variables */
  }
}
```

### Component-Specific Dark Adjustments

Sometimes you need small tweaks per component:

```css
.btn {
  --btn-hover-brightness: 0.9;  /* Darken on hover in light mode */

  /* In dark mode, lighten instead of darken */
  html[data-theme="dark"] & {
    --btn-hover-brightness: 1.25;
  }
}

.card {
  box-shadow: var(--shadow);

  /* Add a subtle border in dark mode where shadows don't show well */
  html[data-theme="dark"] & {
    box-shadow: 0 0 0 1px var(--color-ink-lighter);
  }
}
```

---

## Putting It All Together

### Complete Example: Building a Badge Component

Let's build a badge component from scratch using everything we've learned:

**1. Create the file:** `app/assets/stylesheets/components/badges.css`

```css
@layer components {
  /* ==========================================================================
     Badge Component
     A small label for categorization or status indication.
     ========================================================================== */

  /* Base
  /* ------------------------------------------------------------------------ */

  .badge {
    /* Component API - these variables can be overridden by modifiers */
    --badge-background: var(--color-ink-lightest);
    --badge-color: var(--color-ink);
    --badge-border-color: transparent;
    --badge-padding-block: 0.25em;
    --badge-padding-inline: 0.75em;
    --badge-radius: 99rem;
    --badge-font-size: var(--text-x-small);
    --badge-font-weight: 600;

    /* Structure */
    display: inline-flex;
    align-items: center;
    gap: 0.5ch;

    /* Sizing - using logical properties */
    padding-block: var(--badge-padding-block);
    padding-inline: var(--badge-padding-inline);

    /* Appearance */
    background-color: var(--badge-background);
    color: var(--badge-color);
    border: 1px solid var(--badge-border-color);
    border-radius: var(--badge-radius);

    /* Typography */
    font-size: var(--badge-font-size);
    font-weight: var(--badge-font-weight);
    line-height: 1;
    white-space: nowrap;

    /* Icon sizing */
    .icon {
      --icon-size: 1em;
    }
  }

  /* Variants
  /* ------------------------------------------------------------------------ */

  .badge--primary {
    --badge-background: var(--color-link);
    --badge-color: var(--color-ink-inverted);
  }

  .badge--success {
    --badge-background: var(--color-positive);
    --badge-color: var(--color-ink-inverted);
  }

  .badge--warning {
    --badge-background: var(--color-highlight);
    --badge-color: var(--color-ink);
  }

  .badge--danger {
    --badge-background: var(--color-negative);
    --badge-color: var(--color-ink-inverted);
  }

  .badge--outline {
    --badge-background: transparent;
    --badge-border-color: currentColor;
  }

  /* Sizes
  /* ------------------------------------------------------------------------ */

  .badge--small {
    --badge-padding-block: 0.125em;
    --badge-padding-inline: 0.5em;
    --badge-font-size: var(--text-xx-small);
  }

  .badge--large {
    --badge-padding-block: 0.5em;
    --badge-padding-inline: 1em;
    --badge-font-size: var(--text-small);
  }
}
```

**2. Use it in HTML:**

```html
<!-- Default badge -->
<span class="badge">Default</span>

<!-- With icon -->
<span class="badge badge--success">
  <svg class="icon">...</svg>
  Completed
</span>

<!-- Combining modifiers -->
<span class="badge badge--danger badge--small">Urgent</span>

<!-- Outline variant -->
<span class="badge badge--outline">Draft</span>
```

**3. In Rails ERB:**

```erb
<span class="badge badge--<%= status_variant(idea.status) %>">
  <%= lucide_icon status_icon(idea.status) %>
  <%= idea.status.name %>
</span>
```

---

## Quick Reference Card

### BEM Naming
```
.block              → The component
.block__element     → Part of component
.block--modifier    → Variation
```

### CSS Variables
```css
:root { --color-primary: blue; }     /* Define */
.btn { color: var(--color-primary); } /* Use */
.btn { color: var(--missing, red); }  /* Fallback */
```

### CSS Layers
```css
@layer reset, base, components, utilities;  /* Order = priority */
@layer components { .btn { } }              /* Place styles in layer */
```

### Logical Properties
```css
inline-size      /* width */
block-size       /* height */
padding-inline   /* padding-left + padding-right */
padding-block    /* padding-top + padding-bottom */
margin-inline-start  /* margin-left (in LTR) */
inset: 0         /* top/right/bottom/left: 0 */
```

### Modern Selectors
```css
.parent { .child { } }           /* Nesting */
.btn:has(.icon) { }              /* Parent has child */
.btn:where(:hover) { }           /* Zero specificity */
.btn :is(input, select) { }      /* Match any */
```

---

## Next Steps

1. **Read Fizzy's code** - The repo is at `/tmp/fizzy` (we cloned it)
2. **Start small** - Pick one component and study it deeply
3. **Practice** - Try converting a simple Tailwind component to this style
4. **Ask questions** - This is a lot to absorb!

The best way to learn is by doing. Try taking one of FeedbackBin's current components and rewriting it in the Fizzy style.
