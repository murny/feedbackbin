import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.boundHandleKeydown = this.#handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  #handleKeydown(event) {
    if (event.key !== "v" && event.key !== "V") return
    if (this.#shouldIgnore(event)) return

    const focusedItem = document.activeElement?.closest("[data-navigable-list-target~='item']")
    if (!focusedItem) return

    const voteForm = focusedItem.querySelector("form[action*='/vote']")
    if (!voteForm) return

    event.preventDefault()
    voteForm.requestSubmit()
  }

  #shouldIgnore(event) {
    if (event.defaultPrevented) return true
    if (event.metaKey || event.ctrlKey || event.altKey) return true
    return Boolean(event.target.closest("input, textarea, lexxy-editor, [contenteditable='true']"))
  }
}
