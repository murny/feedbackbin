import { Controller } from "@hotwired/stimulus"

// Dialog controller for managing modal and non-modal dialogs
// Handles opening/closing, lazy frame loading, and accessibility
export default class extends Controller {
  static targets = [ "dialog" ]
  static values = {
    modal: { type: Boolean, default: false }
  }

  connect() {
    this.dialogTarget.setAttribute("aria-hidden", "true")
  }

  open(event) {
    if (event) event.stopPropagation()

    if (this.modalValue) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.show()
    }

    this.loadLazyFrames()
    this.dialogTarget.setAttribute("aria-hidden", "false")
    this.dispatch("show")
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (this.dialogTarget.open) {
      this.close()
    } else {
      this.open()
    }
  }

  close(event) {
    if (event) event.preventDefault()

    this.dialogTarget.close()
    this.dialogTarget.setAttribute("aria-hidden", "true")
    this.dialogTarget.blur()
    this.dispatch("close")
  }

  closeOnClickOutside({ target }) {
    if (!this.element.contains(target)) this.close()
  }

  preventCloseOnMorphing(event) {
    if (event.detail?.attributeName === "open") {
      event.preventDefault()
      event.stopPropagation()
    }
  }

  loadLazyFrames() {
    Array.from(this.dialogTarget.querySelectorAll("turbo-frame")).forEach(frame => {
      frame.loading = "eager"
    })
  }
}
