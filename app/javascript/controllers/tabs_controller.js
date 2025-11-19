import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["activeTab", "inactiveTab"]
  static targets = ["tab", "panel", "select"]
  static values = {
    index: { type: Number, default: 0 },
    updateAnchor: { type: Boolean, default: false },
    scrollToAnchor: { type: Boolean, default: false },
    scrollActiveTabIntoView: { type: Boolean, default: false }
  }

  initialize() {
    if (this.updateAnchorValue && this.anchor) {
      this.indexValue = this.tabTargets.findIndex((tab) => tab.id === this.anchor)
    }
  }

  connect() {
    this.showTab()
  }

  // Changes to the clicked tab
  change(event) {
    event.preventDefault()

    // Don't change to disabled tabs
    if (event.currentTarget.disabled) return

    if (event.currentTarget.tagName === "SELECT") {
      this.indexValue = event.currentTarget.selectedIndex
    } else if (event.currentTarget.dataset.index) {
      this.indexValue = parseInt(event.currentTarget.dataset.index)
    } else if (event.currentTarget.dataset.id) {
      this.indexValue = this.tabTargets.findIndex((tab) => tab.id == event.currentTarget.dataset.id)
    } else {
      this.indexValue = this.tabTargets.indexOf(event.currentTarget)
    }
  }

  nextTab(event) {
    if (event) event.preventDefault()

    let nextIndex = Math.min(this.indexValue + 1, this.tabsCount - 1)
    // Skip disabled tabs
    while (nextIndex < this.tabsCount && this.tabTargets[nextIndex]?.disabled) {
      nextIndex++
    }
    if (nextIndex < this.tabsCount && !this.tabTargets[nextIndex]?.disabled) {
      this.indexValue = nextIndex
      this.tabTargets[nextIndex].focus()
    }
  }

  previousTab(event) {
    if (event) event.preventDefault()

    let prevIndex = Math.max(this.indexValue - 1, 0)
    // Skip disabled tabs
    while (prevIndex >= 0 && this.tabTargets[prevIndex]?.disabled) {
      prevIndex--
    }
    if (prevIndex >= 0 && !this.tabTargets[prevIndex]?.disabled) {
      this.indexValue = prevIndex
      this.tabTargets[prevIndex].focus()
    }
  }

  firstTab() {
    this.indexValue = 0
  }

  lastTab() {
    this.indexValue = this.tabsCount - 1
  }

  indexValueChanged() {
    this.showTab()
    this.dispatch("tab-change", {
      target: this.tabTargets[this.indexValue],
      detail: {
        activeIndex: this.indexValue
      }
    })

    // Update URL with the tab ID if it has one
    // This will be automatically selected on page load
    if (this.updateAnchorValue) {
      const new_tab_id = this.tabTargets[this.indexValue].id
      if (new_tab_id) {
        if (this.scrollToAnchorValue) {
          location.hash = new_tab_id
        } else {
          const currentUrl = window.location.href
          const newUrl = currentUrl.split('#')[0] + '#' + new_tab_id
          if (typeof Turbo !== 'undefined') {
            Turbo.navigator.history.replace(new URL(newUrl))
          } else {
            history.replaceState({}, document.title, newUrl)
          }
        }
      }
    }
  }

  showTab() {
    this.panelTargets.forEach((panel, index) => {
      const tab = this.tabTargets[index]
      const isActive = index === this.indexValue

      if (isActive) {
        panel.classList.remove('hidden')
        panel.removeAttribute('hidden')
        panel.dataset.state = 'active'
        tab.ariaSelected = 'true'
        tab.dataset.active = true
        tab.dataset.state = 'active'
        if (this.hasInactiveTabClass) tab?.classList?.remove(...this.inactiveTabClasses)
        if (this.hasActiveTabClass) tab?.classList?.add(...this.activeTabClasses)
      } else {
        panel.classList.add('hidden')
        panel.setAttribute('hidden', '')
        panel.dataset.state = 'inactive'
        tab.ariaSelected = null
        delete tab.dataset.active
        tab.dataset.state = 'inactive'
        if (this.hasActiveTabClass) tab?.classList?.remove(...this.activeTabClasses)
        if (this.hasInactiveTabClass) tab?.classList?.add(...this.inactiveTabClasses)
      }
    })

    if (this.hasSelectTarget) {
      this.selectTarget.selectedIndex = this.indexValue
    }

    if (this.scrollActiveTabIntoViewValue) this.scrollToActiveTab()
  }

  // If tabs have horizontal scrolling, the active tab may be out of sight.
  // Make sure the active tab is visible by scrolling it into the view.
  scrollToActiveTab() {
    const activeTab = this.element.querySelector('[aria-selected="true"]')
    if (activeTab) activeTab.scrollIntoView({ inline: 'center', block: 'nearest' })
  }

  get tabsCount() {
    return this.tabTargets.length
  }

  get anchor() {
    return (document.URL.split('#').length > 1) ? document.URL.split('#')[1] : null
  }
}
