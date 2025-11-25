import { Controller } from "@hotwired/stimulus"
import { transition } from "helpers/transition"

// Reusable toggle controller with smooth animations
// Can toggle visibility of one or more elements
// Manages ARIA attributes for accessibility
//
// Usage:
//   <div data-controller="toggle">
//     <button data-action="toggle#toggle" data-toggle-target="trigger">Toggle</button>
//     <div data-toggle-target="toggleable" class="hidden">Content</div>
//   </div>
export default class extends Controller {
  static targets = ["toggleable", "trigger"]
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
  }

  // Sets open state based on checkbox or radio input
  toggleInput(event) {
    this.openValue = event.target.checked
  }

  // Explicitly hide
  hide(event) {
    if (event) event.preventDefault()
    this.openValue = false
  }

  // Explicitly show
  show(event) {
    if (event) event.preventDefault()
    this.openValue = true
  }

  // Value change callback - single source of truth for state changes
  // Syncs visuals and ARIA attributes when open state changes
  openValueChanged() {
    this.animate()
    this.updateAria()
  }

  // Animate all toggleable targets
  animate() {
    this.toggleableTargets.forEach(target => {
      transition(target, this.openValue)
    })
  }

  // Update ARIA attributes for accessibility
  updateAria() {
    // Update aria-expanded on trigger elements (e.g., buttons)
    if (this.hasTriggerTarget) {
      this.triggerTargets.forEach(trigger => {
        trigger.setAttribute('aria-expanded', this.openValue)
      })
    }

    // Update aria-hidden on toggleable content
    this.toggleableTargets.forEach(target => {
      target.setAttribute('aria-hidden', !this.openValue)
    })
  }
}
