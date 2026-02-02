import { Controller } from "@hotwired/stimulus";

// Generic form controller for auto-submit and form enhancements
// Includes IME composition tracking for international input
export default class extends Controller {
  static targets = ["cancel", "submit", "input"]

  #isComposing = false

  // IME Composition tracking (important for international input methods like Chinese, Japanese, Korean)
  compositionStart() {
    this.#isComposing = true
  }

  compositionEnd() {
    this.#isComposing = false
  }

  // Submits the form (used by radio buttons, auto-submit, etc.)
  submit() {
    this.element.requestSubmit();
  }

  // Prevent empty form submissions
  preventEmptySubmit(event) {
    const input = this.hasInputTarget ? this.inputTarget : null

    if (input) {
      const value = (input.value || "").trim()
      const isEmpty = value.length === 0

      if (isEmpty) {
        event.preventDefault()
        input.setCustomValidity("Please fill out this field")
        input.reportValidity()
        input.addEventListener("input", () => input.setCustomValidity(""), { once: true })
      }
    }
  }

  // Prevent submission while user is composing (IME)
  preventComposingSubmit(event) {
    if (this.#isComposing) {
      event.preventDefault()
    }
  }

  // Clicks the cancel button/link if present
  cancel() {
    this.cancelTarget?.click();
  }

  // Prevents file attachments (useful for rich text areas)
  preventAttachment(event) {
    event.preventDefault();
  }

  // Resets the form
  reset() {
    this.element.reset()
  }
}
