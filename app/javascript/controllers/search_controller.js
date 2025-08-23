import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"

export default class extends Controller {
  static targets = ["form", "input"]
  static classes = ["loading", "filtering"]
  static values = {
    delay: { type: Number, default: 300 }
  }

  initialize() {
    this.search = debounce(this.search.bind(this), this.delayValue)
  }

  connect() {
    this.inputTarget.focus()
  }

  search(event) {
    const query = event.target.value.trim()

    if (query === "") {
      this.#reset()
    } else {
      this.#activate()
    }

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
}