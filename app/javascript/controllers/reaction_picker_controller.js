import { Controller } from "@hotwired/stimulus"

// Controls the emoji picker popover for reactions
export default class extends Controller {
  static targets = ["menu"]
  static values = { openOnConnect: { type: Boolean, default: false } }

  connect() {
    this.hideOnClickOutside = this.hideOnClickOutside.bind(this)
    this.hideOnEscape = this.hideOnEscape.bind(this)

    // Check if menu is already visible (no hidden class)
    this.isOpen = !this.menuTarget.classList.contains("hidden")

    // If open on connect or already visible, set up listeners
    if (this.openOnConnectValue || this.isOpen) {
      this.isOpen = true
      this.menuTarget.classList.remove("hidden")
      requestAnimationFrame(() => this.addGlobalListeners())
    }
  }

  disconnect() {
    this.removeGlobalListeners()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      this.hide()
    } else {
      this.show()
    }
  }

  show() {
    this.isOpen = true
    this.menuTarget.classList.remove("hidden")
    this.addGlobalListeners()
  }

  hide() {
    this.isOpen = false
    this.menuTarget.classList.add("hidden")
    this.removeGlobalListeners()
  }

  addGlobalListeners() {
    document.addEventListener("click", this.hideOnClickOutside)
    document.addEventListener("keydown", this.hideOnEscape)
  }

  removeGlobalListeners() {
    document.removeEventListener("click", this.hideOnClickOutside)
    document.removeEventListener("keydown", this.hideOnEscape)
  }

  hideOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hide()
    }
  }

  hideOnEscape(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.hide()
    }
  }
}
