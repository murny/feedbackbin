import { Controller } from "@hotwired/stimulus"
import { transition } from "helpers/transition"

// Reusable toggle controller with smooth animations
// Can toggle visibility of one or more elements
//
// Usage:
//   <div data-controller="toggle">
//     <button data-action="toggle#toggle">Toggle</button>
//     <div data-toggle-target="toggleable" class="hidden">Content</div>
//   </div>
export default class extends Controller {
  static targets = ["toggleable"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    // Initialize state for all toggleable elements
    this.toggleableTargets.forEach(target => {
      if (!this.openValue) {
        target.classList.add('hidden')
      }
    })
  }

  // Toggle between open and closed
  toggle(event) {
    if (event) event.preventDefault()
    this.openValue = !this.openValue
    this.animate()
  }

  // Sets open state based on checkbox or radio input
  toggleInput(event) {
    this.openValue = event.target.checked
    this.animate()
  }

  // Explicitly hide
  hide(event) {
    if (event) event.preventDefault()
    this.openValue = false
    this.animate()
  }

  // Explicitly show
  show(event) {
    if (event) event.preventDefault()
    this.openValue = true
    this.animate()
  }

  // Animate all toggleable targets
  animate() {
    this.toggleableTargets.forEach(target => {
      transition(target, this.openValue)
    })
  }

  // Value change callback - can be used to sync state
  openValueChanged() {
    // Optional: add logic when open state changes
  }
}
