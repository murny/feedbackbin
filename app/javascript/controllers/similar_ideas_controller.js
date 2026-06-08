import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"

export default class extends Controller {
  static targets = ["input", "frame"]
  static values = {
    url: String,
    minLength: { type: Number, default: 3 }
  }

  initialize() {
    this.search = debounce(this.#performSearch.bind(this), 300)
  }

  #performSearch() {
    const title = this.inputTarget.value.trim()
    if (title.length < this.minLengthValue) {
      this.frameTarget.removeAttribute("src")
      this.frameTarget.innerHTML = ""
      return
    }
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("title", title)
    this.frameTarget.src = url.toString()
  }
}
