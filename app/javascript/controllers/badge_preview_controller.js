import { Controller } from "@hotwired/stimulus"

// Generic badge/label preview controller
// Works for any form that needs live preview of name + color changes
//
// Usage:
//   data-controller="badge-preview"
//
// Targets:
//   data-badge-preview-target="nameInput"   - The name input field
//   data-badge-preview-target="colorInput"  - The color input field
//   data-badge-preview-target="previewName" - Element to update with name text
//   data-badge-preview-target="previewColor" - Element to update with color
//
// Actions:
//   data-action="input->badge-preview#updatePreview"

export default class extends Controller {
  static targets = ["nameInput", "colorInput", "previewName", "previewColor"]

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const name = this.nameInputTarget.value
    const color = this.colorInputTarget.value

    // Update name text
    if (this.hasPreviewNameTarget) {
      this.previewNameTarget.textContent = name
    }

    // Update color
    if (this.hasPreviewColorTarget) {
      this.previewColorTarget.style.setProperty("--badge-background", color)
    }
  }
}
