import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="popover"
export default class extends Controller {
  static targets = ["content"]
  static values = {
    dismissAfter: Number,
    trigger: { type: String, default: "click" } // "click" or "hover"
  }

  connect() {
    // Set initial state
    this.contentTarget.setAttribute("data-state", "closed")

    // Bind methods to maintain context
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    this.hideOnEscape = this.hideOnEscape.bind(this)
  }

  disconnect() {
    // Clean up any pending timeouts
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    // Remove event listeners
    this.removeGlobalListeners()
  }

  show() {
    this.contentTarget.classList.remove("hidden")
    this.contentTarget.setAttribute("data-state", "open")

    // Add global listeners when popover opens
    this.addGlobalListeners()

    // Auto-dismiss if configured
    if (this.hasDismissAfterValue && this.dismissAfterValue > 0) {
      this.timeout = setTimeout(() => {
        this.hide()
      }, this.dismissAfterValue)
    }
  }

  hide() {
    this.contentTarget.classList.add("hidden")
    this.contentTarget.setAttribute("data-state", "closed")

    // Remove global listeners when popover closes
    this.removeGlobalListeners()

    // Clear any pending timeout
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  toggle() {
    if (this.contentTarget.classList.contains("hidden")) {
      this.show()
    } else {
      this.hide()
    }
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

  // Private methods

  addGlobalListeners() {
    // Listen for clicks outside the popover
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
