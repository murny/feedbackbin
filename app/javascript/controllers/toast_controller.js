import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    dismissAfter: { type: Number, default: 5000 }
  }

  connect() {
    // Set initial state
    this.element.dataset.state = "open"

    // Auto-dismiss if configured
    if (this.dismissAfterValue > 0) {
      this.timeout = setTimeout(() => {
        this.close()
      }, this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  close() {
    // Clear timeout if exists
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }

    // Set closed state for animation
    this.element.dataset.state = "closed"

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300) // Match animation duration
  }

  // Allow external pause (e.g., on hover)
  pause() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
  }

  // Resume auto-dismiss
  resume() {
    if (this.dismissAfterValue > 0 && !this.timeout) {
      this.timeout = setTimeout(() => {
        this.close()
      }, this.dismissAfterValue)
    }
  }
}
