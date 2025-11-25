import { Controller } from "@hotwired/stimulus"
import { transition } from "tailwindcss-stimulus-components"

// Connects to data-controller="popover"
export default class extends Controller {
  static targets = ["content", "trigger"]
  static values = {
    dismissAfter: Number,
    trigger: { type: String, default: "click" }, // "click" or "hover"
    open: { type: Boolean, default: false }
  }

  connect() {
    // Bind methods to maintain context for event listeners
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    this.hideOnEscape = this.hideOnEscape.bind(this)
    this.trapFocus = this.trapFocus.bind(this)
  }

  disconnect() {
    // Clean up
    this.cancelDismissal()
    this.removeGlobalListeners()
  }

  // Stimulus value change callback - handles all transitions
  openValueChanged() {
    if (this.openValue) {
      this.showPopover()
    } else {
      this.hidePopover()
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

  showPopover() {
    if (!this.hasContentTarget) return

    // Update ARIA attributes for accessibility
    this.contentTarget.setAttribute("data-state", "open")
    this.contentTarget.setAttribute("aria-hidden", "false")

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }

    // Use transition helper for smooth animations
    transition(this.contentTarget, true)

    // Focus management - move focus into popover after animation
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.contentTarget.focus()
      })
    })

    // Add event listeners
    this.addGlobalListeners()

    // Add focus trap
    document.addEventListener("keydown", this.trapFocus)

    // Schedule auto-dismiss if configured
    if (this.shouldAutoDismiss) {
      this.scheduleDismissal()
    }
  }

  hidePopover() {
    if (!this.hasContentTarget) return

    // Update ARIA attributes
    this.contentTarget.setAttribute("data-state", "closed")
    this.contentTarget.setAttribute("aria-hidden", "true")

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", "false")
      // Return focus to trigger
      this.triggerTarget.focus()
    }

    // Use transition helper for smooth animations
    transition(this.contentTarget, false)

    // Remove event listeners
    this.removeGlobalListeners()
    document.removeEventListener("keydown", this.trapFocus)

    // Cancel any pending dismissal
    this.cancelDismissal()
  }

  toggle(event) {
    if (event) {
      event.preventDefault()
      event.stopPropagation()
    }
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
    document.addEventListener("click", this.hideOnClickOutside)

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
      event.preventDefault()
      this.hide()
    }
  }

  // Focus trap - keep focus within popover when open
  trapFocus(event) {
    if (event.key !== "Tab" || !this.openValue) return

    const focusableElements = this.contentTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    const focusableArray = Array.from(focusableElements)
    const firstElement = focusableArray[0]
    const lastElement = focusableArray[focusableArray.length - 1]

    // If no focusable elements, prevent tab
    if (focusableArray.length === 0) {
      event.preventDefault()
      return
    }

    // Shift + Tab
    if (event.shiftKey) {
      if (document.activeElement === firstElement || document.activeElement === this.contentTarget) {
        event.preventDefault()
        lastElement.focus()
      }
    }
    // Tab
    else {
      if (document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }
}
