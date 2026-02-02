import { Controller } from "@hotwired/stimulus"

// Hotkey controller for handling keyboard shortcuts
// Triggers clicks or focus on elements when keyboard shortcuts are pressed
export default class extends Controller {
  click(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.click()
    }
  }

  focus(event) {
    if (this.#isClickable && !this.#shouldIgnore(event)) {
      event.preventDefault()
      this.element.focus()
    }
  }

  #shouldIgnore(event) {
    return event.defaultPrevented || event.target.closest("input, textarea, lexxy-editor")
  }

  get #isClickable() {
    return getComputedStyle(this.element).pointerEvents !== "none"
  }
}
