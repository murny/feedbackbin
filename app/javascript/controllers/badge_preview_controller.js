import { Controller } from "@hotwired/stimulus"

// Generic badge/label preview controller
// Works for any form that needs live preview of name + color changes
//
// Supports two preview modes:
// 1. Badge mode (default): Color fills entire badge background
// 2. Circle mode: Color fills only a small circle indicator
//
// Usage:
//   data-controller="badge-preview"
//   data-badge-preview-mode-value="badge|circle"  // Optional, defaults to "badge"
//
// Targets:
//   data-badge-preview-target="nameInput"   - The name input field
//   data-badge-preview-target="colorInput"  - The color input field
//   data-badge-preview-target="previewName" - Element to update with name text
//   data-badge-preview-target="previewColor" - Element to update with color (badge bg or circle)
//
// Actions:
//   data-action="input->badge-preview#updatePreview"

export default class extends Controller {
  static targets = ["nameInput", "colorInput", "previewName", "previewColor"]
  static values = {
    mode: { type: String, default: "badge" }, // "badge" or "circle"
    defaultName: { type: String, default: "Preview" },
    defaultColor: { type: String, default: "#3b82f6" }
  }

  connect() {
    this.updatePreview()
  }

  updatePreview() {
    const name = this.nameInputTarget.value || this.defaultNameValue
    const color = this.colorInputTarget.value || this.defaultColorValue

    // Update name text
    if (this.hasPreviewNameTarget) {
      this.previewNameTarget.textContent = name
    }

    // Update color based on mode
    if (this.hasPreviewColorTarget) {
      this.previewColorTarget.style.backgroundColor = color
    }
  }
}
