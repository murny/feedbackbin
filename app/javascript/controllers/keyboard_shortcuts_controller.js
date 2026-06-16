import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  connect() {
    this.boundHandleKeydown = this.#handleGlobalKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  #handleGlobalKeydown(event) {
    if (event.key !== "?") return
    if (event.metaKey || event.ctrlKey || event.altKey) return
    if (this.#shouldIgnore(event)) return

    event.preventDefault()

    if (this.dialogTarget.open) {
      this.close()
    } else {
      this.open()
    }
  }

  #shouldIgnore(event) {
    return event.defaultPrevented ||
           event.target.closest("input, textarea, lexxy-editor, [contenteditable='true']")
  }
}
