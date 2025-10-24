import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"

export default class extends Controller {
  static targets = ["form", "input"]
  static classes = ["loading", "filtering"]
  static values = {
    delay: { type: Number, default: 300 },
    autofocus: { type: Boolean, default: true }
  }

  initialize() {
    this.search = debounce(this.search.bind(this), this.delayValue)
  }

  connect() {
    if (this.autofocusValue) {
      this.inputTarget.focus()
    }
  }

  search(event) {
    const query = event.target.value.trim()

    if (query === "") {
      this.#reset()
    } else {
      this.#activate()
    }

    // Remove hidden fields with empty values before submitting
    this.#cleanEmptyParams()

    this.element.classList.add(this.loadingClass)
    this.formTarget.requestSubmit()
  }

  // Called when Turbo Frame finishes loading
  searchComplete() {
    this.element.classList.remove(this.loadingClass)
  }

  #activate() {
    this.inputTarget.classList.add(this.filteringClass)
  }

  #reset() {
    this.inputTarget.classList.remove(this.filteringClass)
  }

  #cleanEmptyParams() {
    // Disable hidden input fields that have empty or null values
    // Disabled inputs are not submitted with the form
    const hiddenInputs = this.formTarget.querySelectorAll('input[type="hidden"]')
    hiddenInputs.forEach(input => {
      if (!input.value || input.value.trim() === '') {
        input.disabled = true
      } else {
        input.disabled = false
      }
    })
  }
}