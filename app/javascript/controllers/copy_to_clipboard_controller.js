import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String, successTitle: String }
  static classes = [ "success" ]

  async copy(event) {
    event.preventDefault()
    this.reset()

    try {
      await navigator.clipboard.writeText(this.contentValue)
      this.#showSuccess()
    } catch (error) {
      console.error("Failed to copy to clipboard", error)
    }
  }

  reset() {
    this.element.classList.remove(this.successClass)
    this.#forceReflow()
  }

  #forceReflow() {
    // Access offsetWidth to force browser reflow for CSS transitions
    this.element.offsetWidth
  }

  #showSuccess() {
    const originalTitle = this.element.title
    const originalTooltip = this.element.dataset.tooltip

    this.element.classList.add(this.successClass)
    this.element.title = this.successTitleValue
    this.element.dataset.tooltip = this.successTitleValue

    // Clear any pending timeout
    if (this.successTimeout) {
      clearTimeout(this.successTimeout)
    }

    this.successTimeout = setTimeout(() => {
      this.element.title = originalTitle
      if (originalTooltip) {
        this.element.dataset.tooltip = originalTooltip
      }
      this.reset()
    }, 1500)
  }
}
