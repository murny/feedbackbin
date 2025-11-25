import { Controller } from "@hotwired/stimulus"

// Toast notification controller for managing toast lifecycle
// Supports:
// - Auto-dismiss with configurable timing
// - Pause on hover to read longer messages
// - Keyboard interaction (Escape to dismiss)
// - Turbo cache compatibility
export default class extends Controller {
  static values = {
    dismissAfter: Number
  }

  connect() {
    this.element.dataset.state = "open"

    if (this.hasDismissAfterValue && this.dismissAfterValue > 0) {
      this.remainingTime = this.dismissAfterValue
      this.startedAt = Date.now()
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.remainingTime)
    }
  }

  disconnect() {
    this.#clearTimeout()
  }

  // Runs leave animation and then removes element from the page
  close() {
    this.#clearTimeout()

    // Set closed state for animation, then remove
    this.element.dataset.state = 'closed'

    // Wait for animation to complete before removing
    setTimeout(() => {
      this.element.remove()
    }, 300) // Match animation duration from Tailwind
  }

  // Pause auto-dismiss on hover
  pause() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      this.dismissTimeout = null

      const now = Date.now()
      const elapsed = now - this.startedAt
      this.remainingTime = Math.max(0, this.remainingTime - elapsed)
      this.pausedAt = now
    }
  }

  // Resume auto-dismiss after hover
  resume() {
    if (this.hasDismissAfterValue && this.remainingTime > 0) {
      this.startedAt = Date.now()
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.remainingTime)
      this.pausedAt = null
    }
  }

  #clearTimeout() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      this.dismissTimeout = null
    }
  }
}
