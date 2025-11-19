import { Controller } from "@hotwired/stimulus"
import { enter, leave } from "./transition.js"

export default class extends Controller {
  static values = {
    dismissAfter: Number,
    showDelay: { type: Number, default: 0 }
  }

  connect() {
    // Show toast after optional delay
    setTimeout(() => {
      enter(this.element)
    }, this.showDelayValue)

    // Auto-dismiss if configured
    if (this.hasDismissAfterValue) {
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.dismissAfterValue + this.showDelayValue)
    }
  }

  disconnect() {
    this.#clearTimeouts()
  }

  close() {
    this.#clearTimeouts()

    // Run leave animation and then remove element
    leave(this.element).then(() => {
      this.element.remove()
    })
  }

  // Allow external pause (e.g., on hover)
  pause() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      this.pausedAt = Date.now()
      this.remainingTime = this.dismissAfterValue - (this.pausedAt - this.startedAt)
    }
  }

  // Resume auto-dismiss from where it was paused
  resume() {
    if (this.pausedAt && this.remainingTime > 0) {
      this.dismissTimeout = setTimeout(() => {
        this.close()
      }, this.remainingTime)
      this.startedAt = Date.now()
      this.pausedAt = null
    }
  }

  #clearTimeouts() {
    if (this.dismissTimeout) {
      clearTimeout(this.dismissTimeout)
      this.dismissTimeout = null
    }
  }
}
