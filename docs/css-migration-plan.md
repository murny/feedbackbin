# CSS Migration Plan: Tailwind/Basecoat → Fizzy-style Pure CSS

## Overview

This document outlines a gradual migration strategy to move FeedbackBin from its current Tailwind CSS + Basecoat UI approach to a Fizzy-inspired pure CSS architecture.

### Current State (FeedbackBin)
- **Tailwind CSS 4.x** via `tailwindcss-rails` gem
- **Basecoat UI** - Shadcn-inspired components using `@apply` directives
- **ViewComponents** generating Tailwind utility classes dynamically
- **TailwindMerge** gem for class conflict resolution
- **OKLCH color space** for design tokens (already aligned with Fizzy)
- **~28 component CSS files** in `app/assets/tailwind/components/`

### Target State (Fizzy-style)
- **Pure modern CSS** - no preprocessors, no utility frameworks
- **CSS Layers** (`@layer`) for cascade control
- **BEM-inspired naming** with CSS custom properties as component APIs
- **Modular CSS files** per component/feature
- **No `@apply`** - direct CSS properties only
- **Logical properties** for RTL support

---

## Migration Phases

### Phase 1: Foundation Setup (Week 1-2)
**Goal:** Establish parallel CSS architecture without breaking existing styles

#### 1.1 Create New Directory Structure
```
app/assets/stylesheets/
├── application.css          # New entry point (initially imports both old and new)
├── _global.css              # Design tokens, CSS layers definition
├── reset.css                # Modern CSS reset
├── base.css                 # Base element styling
├── utilities.css            # Minimal utility classes (flex, gap, etc.)
├── components/              # Pure CSS components (migrated from Basecoat)
│   ├── buttons.css
│   ├── badges.css
│   ├── cards.css
│   └── ...
├── modules/                 # Feature-specific styles
│   ├── ideas.css
│   ├── comments.css
│   └── ...
└── platform/                # Platform-specific overrides
    ├── ios.css
    └── android.css
```

#### 1.2 Define CSS Layers
Create `_global.css` with layer order:
```css
@layer reset, base, components, modules, utilities;
```

#### 1.3 Migrate Design Tokens
Transfer existing tokens from `theme.css` to `_global.css`:
- Already using OKLCH - minimal changes needed
- Add Fizzy-style semantic naming pattern
- Establish component-level custom property conventions

#### 1.4 Update Asset Pipeline
- Keep `tailwindcss-rails` temporarily
- Configure Propshaft to serve both CSS sources
- Update layout to load new stylesheet alongside existing

**Deliverables:**
- [ ] New directory structure created
- [ ] `_global.css` with layer definitions and migrated tokens
- [ ] `reset.css` adapted from Fizzy
- [ ] `base.css` with foundational element styles
- [ ] Asset pipeline serving both stylesheets

---

### Phase 2: Component Migration - Core (Week 3-4)
**Goal:** Migrate foundational components to pure CSS

#### 2.1 Button Component
**Current:** `app/assets/tailwind/components/button.css` + `Elements::ButtonComponent`

**Migration steps:**
1. Create `app/assets/stylesheets/components/buttons.css` with pure CSS
2. Use CSS custom properties for variants instead of separate classes
3. Update `Elements::ButtonComponent` to output new class names
4. Test all button variants in Lookbook

**New pattern:**
```css
@layer components {
  .btn {
    --btn-bg: var(--color-canvas);
    --btn-color: var(--color-ink);
    --btn-border: var(--color-border);

    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding-block: 0.5rem;
    padding-inline: 1rem;
    background: var(--btn-bg);
    color: var(--btn-color);
    border: 1px solid var(--btn-border);
    border-radius: var(--radius);
    /* ... */
  }

  .btn--primary {
    --btn-bg: var(--color-primary);
    --btn-color: var(--color-primary-foreground);
    --btn-border: transparent;
  }

  .btn--destructive {
    --btn-bg: var(--color-destructive);
    --btn-color: white;
  }
}
```

#### 2.2 Badge Component
Similar migration pattern as buttons.

#### 2.3 Card Component
Similar migration pattern - cards are heavily used.

#### 2.4 Alert Component
Similar migration pattern.

**Deliverables:**
- [ ] `buttons.css` - pure CSS with all variants
- [ ] `badges.css` - pure CSS
- [ ] `cards.css` - pure CSS
- [ ] `alerts.css` - pure CSS
- [ ] Updated ViewComponents using new classes
- [ ] Lookbook previews passing

---

### Phase 3: Component Migration - Forms (Week 5-6)
**Goal:** Migrate all form-related components

#### Components to migrate:
- [ ] `inputs.css` - text inputs, textareas
- [ ] `selects.css` - native and custom selects
- [ ] `checkboxes.css` - checkbox styling
- [ ] `radios.css` - radio button styling
- [ ] `switches.css` - toggle switches
- [ ] `labels.css` - form labels

#### Form Builder Updates
- Update `app/helpers/form_builders/` to output new class names
- Ensure all form helpers use semantic classes

**Deliverables:**
- [ ] All form component CSS files migrated
- [ ] Form builder helpers updated
- [ ] Form-heavy views tested (settings, idea creation, etc.)

---

### Phase 4: Component Migration - Interactive (Week 7-8)
**Goal:** Migrate interactive/JS-dependent components

#### Components to migrate:
- [ ] `dialogs.css` - modals/dialogs
- [ ] `dropdowns.css` - dropdown menus
- [ ] `popovers.css` - popover panels
- [ ] `tooltips.css` - tooltips
- [ ] `tabs.css` - tab navigation
- [ ] `toasts.css` - toast notifications
- [ ] `collapsibles.css` - expandable sections

#### Stimulus Controller Review
- Ensure controllers work with new class names
- Update any class-based JavaScript queries

**Deliverables:**
- [ ] Interactive component CSS files migrated
- [ ] Stimulus controllers verified/updated
- [ ] All interactive features tested

---

### Phase 5: Layout & Navigation (Week 9-10)
**Goal:** Migrate layout structure and navigation

#### Files to create:
- [ ] `layout.css` - main page structure
- [ ] `sidebar.css` - sidebar navigation
- [ ] `header.css` - header/navbar
- [ ] `navigation.css` - nav components

#### Major layout views to update:
- `app/views/layouts/application.html.erb`
- `app/views/layouts/authenticated.html.erb`
- `app/views/shared/_sidebar.html.erb`
- `app/views/shared/_header.html.erb`

**Deliverables:**
- [ ] Layout CSS files created
- [ ] Main layout templates updated
- [ ] Responsive behavior preserved

---

### Phase 6: Feature Modules (Week 11-12)
**Goal:** Migrate feature-specific styles

#### Modules to create:
- [ ] `ideas.css` - idea cards, list views
- [ ] `comments.css` - comment threads
- [ ] `boards.css` - board views
- [ ] `statuses.css` - status indicators
- [ ] `voting.css` - voting UI
- [ ] `users.css` - user profiles, avatars
- [ ] `settings.css` - settings pages
- [ ] `rich-text.css` - ActionText content

**Deliverables:**
- [ ] All feature modules migrated
- [ ] Feature views updated to use module classes

---

### Phase 7: View Template Migration (Week 13-16)
**Goal:** Remove Tailwind utility classes from all views

This is the most time-consuming phase. Approach systematically:

#### 7.1 Audit Tailwind Usage
Run analysis to find all Tailwind classes in views:
```bash
grep -r "class=" app/views/ | grep -E "(flex|grid|p-|m-|text-|bg-|border-)"
```

#### 7.2 Migration Strategy per View
For each view file:
1. Identify repeated patterns → create semantic classes
2. Replace utility classes with component/module classes
3. Move one-off styles to appropriate CSS files
4. Test thoroughly

#### 7.3 Priority Order
1. Shared partials (highest impact)
2. Layout templates
3. High-traffic views (ideas/index, ideas/show)
4. Settings views
5. Authentication views
6. Remaining views

**Deliverables:**
- [ ] All view templates migrated
- [ ] No Tailwind utility classes in ERB files
- [ ] Minimal utilities.css for remaining needs

---

### Phase 8: Cleanup & Removal (Week 17-18)
**Goal:** Remove Tailwind and finalize architecture

#### 8.1 Remove Tailwind Dependencies
- [ ] Remove `tailwindcss-rails` gem
- [ ] Remove `tailwind_merge` gem
- [ ] Delete `app/assets/tailwind/` directory
- [ ] Update `Gemfile` and run `bundle install`

#### 8.2 Update ViewComponents
- [ ] Remove `tw_merge` helper usage
- [ ] Simplify `BaseComponent` class
- [ ] Update all component classes

#### 8.3 Final Cleanup
- [ ] Remove any remaining Tailwind references
- [ ] Consolidate CSS files if needed
- [ ] Update documentation

#### 8.4 Update Developer Documentation
- [ ] Update `CLAUDE.md` with new CSS conventions
- [ ] Create CSS architecture guide
- [ ] Document component class API

**Deliverables:**
- [ ] Tailwind fully removed
- [ ] Clean, pure CSS architecture
- [ ] Updated documentation

---

## Technical Considerations

### CSS Custom Properties Strategy

**Global tokens** (in `_global.css`):
```css
:root {
  /* Colors - raw OKLCH values */
  --lch-primary: 0.205 0 0;
  --lch-destructive: 0.577 0.245 27.325;

  /* Semantic colors */
  --color-primary: oklch(var(--lch-primary));
  --color-destructive: oklch(var(--lch-destructive));

  /* Spacing scale */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-4: 1rem;

  /* Typography */
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;

  /* Borders */
  --radius: 0.625rem;
  --radius-sm: calc(var(--radius) - 0.25rem);
}

.dark {
  --lch-primary: 0.922 0 0;
  /* ... dark overrides */
}
```

**Component-level properties**:
```css
.card {
  --card-padding: var(--space-4);
  --card-radius: var(--radius);
  --card-bg: var(--color-card);
  --card-border: var(--color-border);

  padding: var(--card-padding);
  border-radius: var(--card-radius);
  background: var(--card-bg);
  border: 1px solid var(--card-border);
}
```

### Logical Properties Adoption

Replace physical properties with logical equivalents:
```css
/* Before (physical) */
padding-left: 1rem;
padding-right: 1rem;
margin-top: 0.5rem;
width: 100%;

/* After (logical) */
padding-inline: 1rem;
margin-block-start: 0.5rem;
inline-size: 100%;
```

### BEM-Inspired Naming Convention

```css
/* Block */
.card { }

/* Element (double underscore) */
.card__header { }
.card__body { }
.card__footer { }

/* Modifier (double dash) */
.card--featured { }
.card--compact { }
```

### Utility Classes (Minimal)

Keep a small set of utilities for common patterns:
```css
@layer utilities {
  .flex { display: flex; }
  .flex-col { flex-direction: column; }
  .items-center { align-items: center; }
  .justify-between { justify-content: space-between; }
  .gap-1 { gap: var(--space-1); }
  .gap-2 { gap: var(--space-2); }
  .gap-4 { gap: var(--space-4); }
  /* ... limited set */
}
```

---

## Risk Mitigation

### Testing Strategy
1. **Lookbook previews** - Verify all component variants
2. **System tests** - Run full suite after each phase
3. **Visual regression** - Screenshot comparisons
4. **Manual QA** - Test responsive behavior, dark mode

### Rollback Plan
- Keep Tailwind active until Phase 8
- Use feature flags if needed for A/B comparison
- Maintain git branches per phase for easy rollback

### Performance Monitoring
- Compare CSS bundle sizes before/after
- Monitor paint/layout metrics
- Ensure no regressions in Core Web Vitals

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| CSS bundle size | ~TBD KB | < 50 KB |
| CSS files | 28 Basecoat + Tailwind | ~40 modular files |
| Build dependencies | tailwindcss-rails, tailwind_merge | None (pure CSS) |
| Utility classes in views | Thousands | < 100 (utilities.css only) |

---

## Timeline Summary

| Phase | Duration | Focus |
|-------|----------|-------|
| 1 | Week 1-2 | Foundation setup |
| 2 | Week 3-4 | Core components |
| 3 | Week 5-6 | Form components |
| 4 | Week 7-8 | Interactive components |
| 5 | Week 9-10 | Layout & navigation |
| 6 | Week 11-12 | Feature modules |
| 7 | Week 13-16 | View template migration |
| 8 | Week 17-18 | Cleanup & removal |

**Total estimated duration: 18 weeks** (can be parallelized with multiple developers)

---

## Quick Start: First Steps

1. Create `app/assets/stylesheets/` directory structure
2. Copy Fizzy's `reset.css` and adapt
3. Create `_global.css` with existing tokens + layer definitions
4. Set up dual-loading in application layout
5. Migrate `ButtonComponent` as proof of concept
6. Iterate based on learnings

---

## References

- [Fizzy Repository](https://github.com/basecamp/fizzy) - Reference implementation
- [CSS Layers Spec](https://developer.mozilla.org/en-US/docs/Web/CSS/@layer)
- [OKLCH Color Space](https://oklch.com/)
- [Logical Properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_logical_properties_and_values)
