import { Controller } from "@hotwired/stimulus"

// Filter controller for real-time filtering of lists
// Hides/shows items based on text input
export default class extends Controller {
  static targets = [ "input", "item", "list" ]

  initialize() {
    this.filter = this.debounce(this.filter.bind(this), 100)
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase().trim()

    this.itemTargets.forEach(item => {
      const text = item.textContent.toLowerCase()
      const matches = text.includes(query)

      if (matches) {
        item.removeAttribute("hidden")
      } else {
        item.toggleAttribute("hidden", true)
      }
    })

    this.dispatch("changed")
  }

  clearInput() {
    if (!this.hasInputTarget) return
    this.inputTarget.value = ""
    this.filter()
  }

  // Simple debounce implementation
  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
