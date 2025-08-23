import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input", "results"]
  static values = { 
    delay: { type: Number, default: 300 },
    minLength: { type: Number, default: 0 }
  }

  connect() {
    this.timeout = null
    this.isSearching = false
  }

  disconnect() {
    this.clearTimeout()
  }

  search() {
    this.clearTimeout()
    
    const query = this.inputTarget.value.trim()
    
    // If query is shorter than minimum length and not empty, don't search
    if (query.length > 0 && query.length < this.minLengthValue) {
      return
    }
    
    // Show that we're about to search
    this.inputTarget.classList.add("animate-pulse")
    
    // Debounce the search
    this.timeout = setTimeout(() => {
      this.submitSearch()
    }, this.delayValue)
  }

  submitSearch() {
    // Remove pulse animation
    this.inputTarget.classList.remove("animate-pulse")
    
    // Add subtle loading indication
    this.inputTarget.classList.add("opacity-75")
    this.isSearching = true
    
    // Submit the form which will trigger the Turbo request
    this.formTarget.requestSubmit()
  }

  // Called when Turbo frame finishes loading
  turboFrameLoad() {
    this.inputTarget.classList.remove("opacity-75")
    this.isSearching = false
  }

  clearTimeout() {
    if (this.timeout) {
      clearTimeout(this.timeout)
      this.timeout = null
    }
    this.inputTarget.classList.remove("animate-pulse")
  }
}