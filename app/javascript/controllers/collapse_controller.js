import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    if (this.contentTarget.style.maxHeight) {
      this.contentTarget.style.maxHeight = null
      this.iconTarget.classList.remove("rotate-90")
    } else {
      this.contentTarget.style.maxHeight = this.contentTarget.scrollHeight + "px"
      this.iconTarget.classList.add("rotate-90")
    }
  }
}