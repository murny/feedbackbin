import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "input"]
  static values = {
    delay: { type: Number, default: 300 }
  }

  connect() {
    this.timeout = null
  }

  disconnect() {
    this.clearDebounce()
  }

  search() {
    this.clearDebounce()

    // Debounce the search
    this.timeout = window.setTimeout(() => {
      this.formTarget.requestSubmit()
    }, this.delayValue)
  }


  clearDebounce() {
    if (this.timeout) {
      window.clearTimeout(this.timeout)
      this.timeout = null
    }
  }
}