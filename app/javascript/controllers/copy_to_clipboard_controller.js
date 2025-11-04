import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { content: String, successTitle: String }
  static classes = [ "success" ]

  async copy(event) {
    event.preventDefault()
    this.reset()

    try {
      await navigator.clipboard.writeText(this.contentValue)
      this.element.classList.add(this.successClass)
      this.#showTooltip()
    } catch {}
  }

  reset() {
    this.element.classList.remove(this.successClass)
    this.#forceReflow()
  }

  #forceReflow() {
    this.element.offsetWidth
  }

  #showTooltip() {
    const originalTitle = this.element.title
    const originalTooltip = this.element.dataset.tooltip

    this.element.title = this.successTitleValue
    this.element.dataset.tooltip = this.successTitleValue

    setTimeout(() => {
      this.element.title = originalTitle
      if (originalTooltip) {
        this.element.dataset.tooltip = originalTooltip
      }
    }, 2000)
  }
}
