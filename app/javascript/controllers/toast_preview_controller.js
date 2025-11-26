import { Controller } from "@hotwired/stimulus"

// Simple controller for Lookbook toast previews
// Spawns toasts when the trigger button is clicked
// Supports stacking toasts with visual offset (Sonner/Shadcn pattern)
export default class extends Controller {
  static targets = ["container", "template"]

  connect() {
    // Create single observer to watch for toast additions/removals
    this.observer = new MutationObserver(() => this.repositionToasts())
    this.observer.observe(this.containerTarget, { childList: true })
  }

  disconnect() {
    // Clean up observer when controller is removed
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
  }

  show(event) {
    event.preventDefault()

    // Clone the template
    const template = this.templateTarget
    const clone = template.content.cloneNode(true)

    // Append to container - observer will automatically trigger repositionToasts()
    this.containerTarget.appendChild(clone)
  }

  repositionToasts() {
    const toasts = Array.from(
      this.containerTarget.querySelectorAll('[data-controller~="toast"]')
    )

    toasts.forEach((toast, index) => {
      // Make the newest toast (last in DOM) the primary one (Sonner/Shadcn pattern)
      if (index === toasts.length - 1) {
        // Newest toast is full size and interactive
        toast.style.transform = 'scale(1) translateY(0)'
        toast.style.opacity = '1'
        toast.style.pointerEvents = 'auto'
      } else {
        // Older toasts are stacked behind with visual offset
        // Calculate offset from the end (newest toast)
        const offsetFromNewest = toasts.length - 1 - index
        const scale = 1 - (offsetFromNewest * 0.05) // Each older toast 5% smaller
        const translateY = -(offsetFromNewest * 8) // Each older toast 8px higher
        const opacity = 1 - (offsetFromNewest * 0.1) // Each older toast slightly more transparent

        toast.style.transform = `scale(${scale}) translateY(${translateY}px)`
        toast.style.opacity = opacity
        toast.style.pointerEvents = 'none'
      }

      // Add transition for smooth animation
      toast.style.transition = 'all 150ms ease-out'
    })
  }
}
