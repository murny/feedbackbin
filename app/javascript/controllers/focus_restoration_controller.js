import { Controller } from "@hotwired/stimulus"
import { isMobile } from "helpers/platform_helpers"

const DOM_ID_PATTERN = /^[a-z0-9_-]+_\d+$/

export default class extends Controller {
  static values = {
    storageKey: { type: String, default: "lastFocusedItem" }
  }

  connect() {
    this.boundHandleActivation = this.#handleActivation.bind(this)
    this.boundHandleRestore = this.#handleRestore.bind(this)

    document.addEventListener("click", this.boundHandleActivation, true)
    document.addEventListener("keydown", this.boundHandleActivation, true)
    document.addEventListener("turbo:load", this.boundHandleRestore)
    document.addEventListener("turbo:render", this.boundHandleRestore)
    window.addEventListener("popstate", this.boundHandleRestore)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHandleActivation, true)
    document.removeEventListener("keydown", this.boundHandleActivation, true)
    document.removeEventListener("turbo:load", this.boundHandleRestore)
    document.removeEventListener("turbo:render", this.boundHandleRestore)
    window.removeEventListener("popstate", this.boundHandleRestore)
  }

  #handleActivation(event) {
    if (isMobile()) return
    if (event.type === "keydown" && event.key !== "Enter") return

    const item = event.target.closest("[data-navigable-list-target~='item']")
    if (!item || !item.id) return

    sessionStorage.setItem(this.storageKeyValue, item.id)
  }

  #handleRestore() {
    if (isMobile()) return

    const id = sessionStorage.getItem(this.storageKeyValue)
    if (!id) return

    if (!DOM_ID_PATTERN.test(id)) {
      sessionStorage.removeItem(this.storageKeyValue)
      return
    }

    const el = document.getElementById(id)
    if (!el) return

    el.focus({ preventScroll: false })
    el.scrollIntoView({ block: "nearest" })

    sessionStorage.removeItem(this.storageKeyValue)
  }
}
