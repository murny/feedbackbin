import { Controller } from "@hotwired/stimulus"

// Controls the expand/collapse behavior of the reply form
// Shows a placeholder button, swaps to real form on click (GitHub Discussions pattern)
export default class extends Controller {
  static targets = ["trigger", "form", "input"]

  expand() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.classList.add("hidden")
      this.triggerTarget.setAttribute("aria-expanded", "true")
    }

    if (this.hasFormTarget) {
      this.formTarget.classList.remove("hidden")

      // Focus the Trix editor
      requestAnimationFrame(() => {
        const trixEditor = this.formTarget.querySelector("trix-editor")
        if (trixEditor) {
          trixEditor.focus()
        }
      })
    }
  }

  collapse() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.classList.remove("hidden")
      this.triggerTarget.setAttribute("aria-expanded", "false")
    }

    if (this.hasFormTarget) {
      this.formTarget.classList.add("hidden")
    }

    // Clear the Trix editor
    if (this.hasFormTarget) {
      const trixEditor = this.formTarget.querySelector("trix-editor")
      if (trixEditor && trixEditor.editor) {
        trixEditor.editor.loadHTML("")
      }
    }
  }
}
