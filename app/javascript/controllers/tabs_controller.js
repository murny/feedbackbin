import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    index: { type: Number, default: 0 }
  }

  connect() {
    this.showTab(this.indexValue)
  }

  change(event) {
    event.preventDefault()
    const clickedTab = event.currentTarget

    // Don't switch if tab is disabled
    if (clickedTab.disabled) return

    const index = this.tabTargets.indexOf(clickedTab)
    this.showTab(index)
  }

  showTab(index) {
    // Skip disabled tabs
    if (this.tabTargets[index]?.disabled) return

    this.indexValue = index

    // Update tabs
    this.tabTargets.forEach((tab, i) => {
      const isActive = i === index

      if (isActive) {
        tab.setAttribute("aria-selected", "true")
        tab.setAttribute("data-state", "active")
      } else {
        tab.setAttribute("aria-selected", "false")
        tab.setAttribute("data-state", "inactive")
      }
    })

    // Update panels
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.removeAttribute("hidden")
        panel.setAttribute("data-state", "active")
      } else {
        panel.setAttribute("hidden", "")
        panel.setAttribute("data-state", "inactive")
      }
    })
  }

  // Keyboard navigation
  nextTab(event) {
    event.preventDefault()
    let nextIndex = (this.indexValue + 1) % this.tabTargets.length

    // Skip disabled tabs
    while (this.tabTargets[nextIndex]?.disabled && nextIndex !== this.indexValue) {
      nextIndex = (nextIndex + 1) % this.tabTargets.length
    }

    if (!this.tabTargets[nextIndex]?.disabled) {
      this.showTab(nextIndex)
      this.tabTargets[nextIndex].focus()
    }
  }

  previousTab(event) {
    event.preventDefault()
    let prevIndex = this.indexValue === 0 ? this.tabTargets.length - 1 : this.indexValue - 1

    // Skip disabled tabs
    while (this.tabTargets[prevIndex]?.disabled && prevIndex !== this.indexValue) {
      prevIndex = prevIndex === 0 ? this.tabTargets.length - 1 : prevIndex - 1
    }

    if (!this.tabTargets[prevIndex]?.disabled) {
      this.showTab(prevIndex)
      this.tabTargets[prevIndex].focus()
    }
  }
}
