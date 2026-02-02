import { Controller } from "@hotwired/stimulus"

// Navigable list controller for keyboard navigation through lists
// Supports arrow key navigation and Enter to select
export default class extends Controller {
  static targets = [ "item" ]
  static values = {
    focusOnSelection: { type: Boolean, default: false },
    actionableItems: { type: Boolean, default: false }
  }

  selectedIndex = 0

  connect() {
    this.#focusSelectedItem()
  }

  navigate(event) {
    const items = this.#visibleItems()
    if (items.length === 0) return

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault()
        this.selectedIndex = Math.min(this.selectedIndex + 1, items.length - 1)
        this.#focusSelectedItem()
        break
      case "ArrowUp":
        event.preventDefault()
        this.selectedIndex = Math.max(this.selectedIndex - 1, 0)
        this.#focusSelectedItem()
        break
      case "Enter":
        if (this.actionableItemsValue) {
          event.preventDefault()
          this.#clickSelectedItem()
        }
        break
    }
  }

  reset() {
    this.selectedIndex = 0
    this.#focusSelectedItem()
  }

  #visibleItems() {
    return this.itemTargets.filter(item => !item.hasAttribute("hidden"))
  }

  #focusSelectedItem() {
    const items = this.#visibleItems()
    if (items.length === 0) return

    const selectedItem = items[this.selectedIndex]
    if (!selectedItem) return

    if (this.focusOnSelectionValue) {
      selectedItem.focus()
    } else {
      selectedItem.scrollIntoView({ block: "nearest", behavior: "smooth" })
    }
  }

  #clickSelectedItem() {
    const items = this.#visibleItems()
    const selectedItem = items[this.selectedIndex]
    if (!selectedItem) return

    const button = selectedItem.querySelector("button, a")
    if (button) {
      button.click()
    }
  }
}
