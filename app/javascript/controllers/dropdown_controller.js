import { Controller } from "@hotwired/stimulus"

// Dropdown menu controller for managing open/close state
// Supports:
// - Click outside to close (configurable)
// - Escape key to close (configurable)
// - Keyboard navigation (arrow keys, home, end)
// - CSS animations via data-state attribute
// - Focus management
// - Turbo cache compatibility
export default class extends Controller {
  static targets = ["menu", "trigger"]
  static values = {
    open: { type: Boolean, default: false },
    closeOnEscape: { type: Boolean, default: true },
    closeOnClickOutside: { type: Boolean, default: true }
  }

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.handleKeyNavigation = this.handleKeyNavigation.bind(this)
    this.beforeCache = this.beforeCache.bind(this)

    // Ensure dropdown is closed before Turbo caches the page
    document.addEventListener("turbo:before-cache", this.beforeCache)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
    document.removeEventListener("keydown", this.closeOnEscape)
    document.removeEventListener("keydown", this.handleKeyNavigation)
    document.removeEventListener("turbo:before-cache", this.beforeCache)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.openValue = !this.openValue
  }

  show() {
    this.openValue = true
  }

  close() {
    this.openValue = false
  }

  openValueChanged() {
    if (this.openValue) {
      this.showMenu()
    } else {
      this.hideMenu()
    }
  }

  showMenu() {
    // Update state for CSS animations (component has data-[state=open]:animate-in classes)
    this.menuTarget.setAttribute("data-state", "open")
    this.triggerTarget.setAttribute("aria-expanded", "true")

    // Add event listeners
    document.addEventListener("click", this.closeOnClickOutside)
    document.addEventListener("keydown", this.closeOnEscape)
    document.addEventListener("keydown", this.handleKeyNavigation)

    // Focus first menu item after a brief delay to allow animation to start
    requestAnimationFrame(() => {
      this.focusFirstItem()
    })
  }

  hideMenu() {
    // Update state for CSS animations (component has data-[state=closed]:animate-out classes)
    this.menuTarget.setAttribute("data-state", "closed")
    this.triggerTarget.setAttribute("aria-expanded", "false")

    // Remove event listeners
    document.removeEventListener("click", this.closeOnClickOutside)
    document.removeEventListener("keydown", this.closeOnEscape)
    document.removeEventListener("keydown", this.handleKeyNavigation)

    // Return focus to trigger
    this.triggerTarget.focus()
  }

  closeOnClickOutside(event) {
    if (this.closeOnClickOutsideValue && !this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (this.closeOnEscapeValue && event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  handleKeyNavigation(event) {
    const items = this.getFocusableItems()
    if (items.length === 0) return

    const currentIndex = items.indexOf(document.activeElement)

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (currentIndex < items.length - 1) {
          items[currentIndex + 1].focus()
        } else {
          items[0].focus() // Loop to first
        }
        break
      case "ArrowUp":
        event.preventDefault()
        if (currentIndex > 0) {
          items[currentIndex - 1].focus()
        } else {
          items[items.length - 1].focus() // Loop to last
        }
        break
      case "Home":
        event.preventDefault()
        items[0]?.focus()
        break
      case "End":
        event.preventDefault()
        items[items.length - 1]?.focus()
        break
    }
  }

  getFocusableItems() {
    return Array.from(
      this.menuTarget.querySelectorAll(
        'a[href], button:not([disabled]), [role="menuitem"]:not([disabled]), [role="menuitemcheckbox"]:not([disabled]), [role="menuitemradio"]:not([disabled])'
      )
    )
  }

  focusFirstItem() {
    const items = this.getFocusableItems()
    items[0]?.focus()
  }

  // Ensures the menu is closed before Turbo caches the page
  beforeCache() {
    this.openValue = false
  }
}
