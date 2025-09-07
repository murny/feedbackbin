import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidebar"
export default class extends Controller {
  static targets = ["overlay"]

  toggle() {
    const overlay = this.overlayTarget
    if (overlay.style.display === "none") {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    const overlay = this.overlayTarget
    overlay.style.display = "block"
    // Prevent body scroll when sidebar is open
    document.body.style.overflow = "hidden"
  }

  close() {
    const overlay = this.overlayTarget
    overlay.style.display = "none"
    // Re-enable body scroll
    document.body.style.overflow = ""
  }

  // Close sidebar when clicking outside
  hideOnClickOutside(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  // Close sidebar on escape key
  hideOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  connect() {
    // Add event listeners
    document.addEventListener("keydown", this.hideOnEscape.bind(this))
    this.overlayTarget.addEventListener("click", this.hideOnClickOutside.bind(this))
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("keydown", this.hideOnEscape.bind(this))
    this.overlayTarget.removeEventListener("click", this.hideOnClickOutside.bind(this))
    // Re-enable body scroll in case it was disabled
    document.body.style.overflow = ""
  }
}