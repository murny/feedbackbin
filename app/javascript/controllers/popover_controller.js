import { Controller } from "@hotwired/stimulus"
import { transition } from "tailwindcss-stimulus-components"

// Connects to data-controller="popover"
export default class extends Controller {
  static targets = ["content"]
  static values = {
    dismissAfter: Number,
    trigger: { type: String, default: "click" }, // "click" or "hover"
    open: { type: Boolean, default: false }
  }

  connect() {
    // Bind methods to maintain context for event listeners
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    this.hideOnEscape = this.hideOnEscape.bind(this)
  }

  disconnect() {
    // Clean up
    this.cancelDismissal()
    this.removeGlobalListeners()
  }

  // Stimulus value change callback - handles all transitions
  openValueChanged() {
    // Update data-state attribute for CSS animations
    this.contentTarget.setAttribute("data-state", this.openValue ? "open" : "closed")

    // Use transition helper for smooth animations
    transition(this.contentTarget, this.openValue)

    if (this.openValue) {
      this.addGlobalListeners()
      if (this.shouldAutoDismiss) {
        this.scheduleDismissal()
      }
    } else {
      this.removeGlobalListeners()
    }
  }

  // Public API methods
  show() {
    // If already open and auto-dismiss is enabled, extend the dismissal
    if (this.shouldAutoDismiss) {
      this.scheduleDismissal()
    }
    this.openValue = true
  }

  hide() {
    this.openValue = false
  }

  toggle() {
    this.openValue = !this.openValue
  }

  // Handle hover show (for hover trigger mode)
  handleMouseEnter() {
    if (this.triggerValue === "hover") {
      this.show()
    }
  }

  // Handle hover hide (for hover trigger mode)
  handleMouseLeave() {
    if (this.triggerValue === "hover") {
      this.hide()
    }
  }

  // Auto-dismiss functionality
  get shouldAutoDismiss() {
    return this.openValue && this.hasDismissAfterValue
  }

  scheduleDismissal() {
    if (!this.hasDismissAfterValue) return

    // Cancel any existing dismissal
    this.cancelDismissal()

    // Schedule the next dismissal
    this.timeoutId = setTimeout(() => {
      this.hide()
      this.timeoutId = undefined
    }, this.dismissAfterValue)
  }

  cancelDismissal() {
    if (typeof this.timeoutId === "number") {
      clearTimeout(this.timeoutId)
      this.timeoutId = undefined
    }
  }

  // Event listener management
  addGlobalListeners() {
    // Listen for clicks outside the popover
    // Delay to avoid immediate triggering from the click that opened it
    setTimeout(() => {
      document.addEventListener("click", this.hideOnClickOutside)
    }, 0)

    // Listen for escape key
    document.addEventListener("keydown", this.hideOnEscape)
  }

  removeGlobalListeners() {
    document.removeEventListener("click", this.hideOnClickOutside)
    document.removeEventListener("keydown", this.hideOnEscape)
  }

  hideOnClickOutside(event) {
    // Don't hide if clicking inside the popover
    if (this.element.contains(event.target)) {
      return
    }

    this.hide()
  }

  hideOnEscape(event) {
    if (event.key === "Escape") {
      this.hide()
    }
  }
}
