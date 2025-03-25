/**
 * Toast Controller
 *
 * Used to control the display of toast notifications. This controller manages
 * toast containers and individual toast items, handling their appearance,
 * animations, and automatic dismissal.
 *
 * Features:
 * - Auto-show toasts when container connects
 * - Control toast display duration
 * - Trigger toasts from buttons/links
 * - Position toasts in different screen locations
 * - Limit the number of visible toasts
 * - Support for action buttons in toasts
 *
 * Example usage:
 *
 * ```erb
 * <!-- Toast container -->
 * <%= render_toast_container(id: "my-toast", limit: 3) do %>
 *   <%= render_toast(
 *     title: "Notification",
 *     description: "This is a toast notification.",
 *     variant: :success,
 *     duration: 5000,
 *     action: {
 *       label: "View",
 *       url: "/items/123"
 *     }
 *   ) %>
 * <% end %>
 *
 * <!-- Button to trigger the toast -->
 * <%= render_button(
 *   text: "Show Toast",
 *   data: {
 *     controller: "ui--toast",
 *     target: "#my-toast"
 *   }
 * ) %>
 * ```
 */
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  static values = {
    duration: { type: Number, default: 3000 },
    autoShow: { type: Boolean, default: false },
    limit: { type: Number, default: 0 }
  }

  initialize() {
    this.activeToasts = new Set()
  }

  connect() {
    // Auto-show the toast region when it connects if auto is not set to false
    if (this.element.role === "region" && this.element.dataset.auto !== "false") {
      setTimeout(() => {
        this.open()
      }, 1000)
    }
  }

  disconnect() {
    // Ensure any running timers are cleaned up
    if (this._autoCloseTimeout) {
      clearTimeout(this._autoCloseTimeout)
    }

    // Clear any stored active toasts
    this.activeToasts.clear()
  }

  open() {
    if (this.hasItemTarget) {
      this.element.dataset.state = "open"
      this.element.classList.remove("hidden")
      this.showToast(this.itemTarget)
    } else {
      this.element.dataset.state = "open"
      this.element.classList.remove("hidden")
    }
  }

  close() {
    if (this.hasItemTarget) {
      this.element.dataset.state = "closed"
      this.element.classList.add("hidden")
      this.closeToast(this.itemTarget)
    } else {
      this.element.dataset.state = "closed"
      this.element.classList.add("hidden")
    }
  }

  showToast(el) {
    if (el) {
      // Enforce limit if specified
      if (this.limitValue > 0 && this.activeToasts.size >= this.limitValue) {
        const oldestToast = this.getOldestActiveToast()
        if (oldestToast) {
          this.closeToast(oldestToast)
        }
      }

      // Show the toast
      el.dataset.state = "open"
      el.classList.remove("hidden")

      // Track active toast
      this.activeToasts.add(el)

      // Auto-close after duration
      const duration = parseInt(el.dataset.duration || this.durationValue, 10)
      if (duration > 0) {
        this._autoCloseTimeout = setTimeout(() => {
          this.closeToast(el)
        }, duration)
      }
    }
  }

  closeToast(el) {
    if (el) {
      el.dataset.state = "closed"

      // Remove from active toasts
      this.activeToasts.delete(el)

      setTimeout(() => {
        el.classList.add("hidden")
      }, 300) // Allow time for animation
    }
  }

  trigger(event) {
    // Support for action URL
    const btnEl = event.currentTarget
    const url = btnEl.dataset.url

    if (url) {
      window.location.href = url
      return
    }

    // Regular trigger functionality
    const idTarget = this.element.dataset.target
    if (idTarget) {
      const toastContainer = document.querySelector(`${idTarget}`)
      if (toastContainer) {
        toastContainer.dataset.state = "open"
        toastContainer.classList.remove("hidden")
        const toastElement = toastContainer.querySelector("[data-ui--toast-target='item']")
        if (toastElement) {
          this.showToast(toastElement)
        }
      }
    }
  }

  openAll() {
    const toastElements = document.querySelectorAll(
      "[data-ui--toast-target='item']:not([data-visible='false'])"
    )
    toastElements.forEach((toastElement) => {
      this.showToast(toastElement)
    })
  }

  closeAll() {
    const toastElements = document.querySelectorAll("[data-ui--toast-target='item']")
    toastElements.forEach((toastElement) => {
      this.closeToast(toastElement)
    })
  }

  // Utility method to find the oldest toast when enforcing limits
  getOldestActiveToast() {
    if (this.activeToasts.size === 0) return null
    return Array.from(this.activeToasts)[0]
  }
}