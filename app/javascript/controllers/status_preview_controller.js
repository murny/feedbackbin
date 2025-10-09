import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge", "nameInput", "colorInput"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const name = this.nameInputTarget.value || "Status Name"
    const color = this.colorInputTarget.value || "#3b82f6"

    this.badgeTarget.textContent = name
    this.badgeTarget.style.backgroundColor = color
  }
}
