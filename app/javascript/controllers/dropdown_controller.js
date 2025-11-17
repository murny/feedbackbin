import { Controller } from "@hotwired/stimulus"

// Dropdown menu controller for managing open/close state
// Supports:
// - Click outside to close
// - Escape key to close
// - Keyboard navigation (arrow keys)
// - Focus management
export default class extends Controller {
  static targets = ["menu", "trigger"]
  static classes = ["hidden"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.handleKeyNavigation = this.handleKeyNavigation.bind(this)
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    this.openValue = !this.openValue
  }

  open() {
    this.openValue = true
  }

  close() {
    this.openValue = false
  }

  openValueChanged() {
    if (this.openValue) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.menuTarget.classList.remove(...this.hiddenClasses)
    this.menuTarget.setAttribute("data-state", "open")
    this.triggerTarget.setAttribute("aria-expanded", "true")

    // Add event listeners
    document.addEventListener("click", this.closeOnClickOutside)
    document.addEventListener("keydown", this.closeOnEscape)
    document.addEventListener("keydown", this.handleKeyNavigation)

    // Focus first menu item
    this.focusFirstItem()
  }

  hide() {
    this.menuTarget.classList.add(...this.hiddenClasses)
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
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  handleKeyNavigation(event) {
    const items = this.getFocusableItems()
    const currentIndex = items.indexOf(document.activeElement)

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        if (currentIndex < items.length - 1) {
          items[currentIndex + 1].focus()
        } else {
          items[0].focus()
        }
        break
      case "ArrowUp":
        event.preventDefault()
        if (currentIndex > 0) {
          items[currentIndex - 1].focus()
        } else {
          items[items.length - 1].focus()
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
        'a[href], button:not([disabled]), [role="menuitem"]:not([disabled])'
      )
    )
  }

  focusFirstItem() {
    const items = this.getFocusableItems()
    items[0]?.focus()
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnClickOutside)
    document.removeEventListener("keydown", this.closeOnEscape)
    document.removeEventListener("keydown", this.handleKeyNavigation)
  }
}
