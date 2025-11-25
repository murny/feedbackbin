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
    // Show toast with enter animation
    // Toast uses data-state attribute for Tailwind's data-[state] selectors
    this.element.dataset.state = 'open'

    // Track start time for pause/resume
    this.startTime = Date.now()

    // Auto-dismiss if configured
    if (this.hasDismissAfterValue && this.dismissAfterValue > 0) {
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.dismissAfterValue)
    }
  }

  disconnect() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }
  }

  // Runs leave animation and then removes element from the page
  close() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
    }

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
      // Calculate remaining time
      this.remainingTime = this.dismissAfterValue - (Date.now() - this.startTime)
    }
  }

  // Resume auto-dismiss after hover
  resume() {
    if (this.hasDismissAfterValue && this.remainingTime > 0) {
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.remainingTime)
    }
  }
}
