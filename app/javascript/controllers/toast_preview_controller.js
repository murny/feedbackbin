import { Controller } from "@hotwired/stimulus"

// Simple controller for Lookbook toast previews
// Spawns toasts when the trigger button is clicked
// Supports stacking toasts with visual offset
export default class extends Controller {
  static targets = ["container", "template"]

  show(event) {
    event.preventDefault()

    // Clone the template
    const template = this.templateTarget
    const clone = template.content.cloneNode(true)

    // Get the toast element from the cloned content
    const toastElement = clone.querySelector('[data-controller*="toast"]')

    if (toastElement) {
      // Count existing toasts in this container
      const existingToasts = this.containerTarget.querySelectorAll('[data-controller*="toast"]')
      const index = existingToasts.length

      // Add stacking styles: scale down and translate up based on position
      // Each toast is slightly smaller and offset
      if (index > 0) {
        const scale = 1 - (index * 0.05) // Each toast 5% smaller
        const translateY = -(index * 8) // Each toast 8px higher
        const opacity = 1 - (index * 0.1) // Each toast slightly more transparent

        toastElement.style.transform = `scale(${scale}) translateY(${translateY}px)`
        toastElement.style.opacity = opacity
        toastElement.style.pointerEvents = index === 0 ? 'auto' : 'none'

        // Add transition for smooth animation
        toastElement.style.transition = 'all 150ms ease-out'
      }

      // When a toast is removed, reposition remaining toasts
      const observer = new MutationObserver(() => {
        this.repositionToasts()
      })

      observer.observe(this.containerTarget, { childList: true })
    }

    // Append to container - Stimulus will automatically connect controllers
    this.containerTarget.appendChild(clone)
  }

  repositionToasts() {
    const toasts = this.containerTarget.querySelectorAll('[data-controller*="toast"]')

    toasts.forEach((toast, index) => {
      if (index === 0) {
        // First toast (top) is full size
        toast.style.transform = 'scale(1) translateY(0)'
        toast.style.opacity = '1'
        toast.style.pointerEvents = 'auto'
      } else {
        // Stack subsequent toasts behind
        const scale = 1 - (index * 0.05)
        const translateY = -(index * 8)
        const opacity = 1 - (index * 0.1)

        toast.style.transform = `scale(${scale}) translateY(${translateY}px)`
        toast.style.opacity = opacity
        toast.style.pointerEvents = 'none'
      }
    })
  }
}
