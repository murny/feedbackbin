import { Controller } from "@hotwired/stimulus";

// Generic form controller for auto-submit and form enhancements
export default class extends Controller {
  static targets = ["cancel"]

  // Submits the form (used by radio buttons, auto-submit, etc.)
  submit() {
    this.element.requestSubmit();
  }

  // Clicks the cancel button/link if present
  cancel() {
    this.cancelTarget?.click();
  }

  // Prevents file attachments (useful for rich text areas)
  preventAttachment(event) {
    event.preventDefault();
  }
}
