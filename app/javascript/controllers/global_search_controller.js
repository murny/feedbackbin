import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"
import { isAppleDevice } from "helpers/platform_helpers"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["dialog", "input", "results"]
  static values = {
    url: String,
    queriesUrl: String,
    delay: { type: Number, default: 200 }
  }

  initialize() {
    this.search = debounce(this.#performSearch.bind(this), this.delayValue)
  }

  connect() {
    this.boundHandleKeydown = this.#handleGlobalKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  open() {
    this.dialogTarget.showModal()
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  close() {
    this.dialogTarget.close()
    this.inputTarget.value = ""
    this.resultsTarget.querySelector("#search_results")?.replaceChildren()
  }

  navigate(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  selectRecentQuery(event) {
    const query = event.currentTarget.dataset.query
    this.inputTarget.value = query
    this.#performSearch()
  }

  async #performSearch() {
    const query = this.inputTarget.value.trim()

    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("q", query)

    const response = await fetch(url, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content
      }
    })

    if (response.ok) {
      const html = await response.text()
      Turbo.renderStreamMessage(html)

      if (query.length >= 3) {
        this.#trackQuery(query)
      }
    }
  }

  async #trackQuery(query) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content
    if (!csrfToken) return

    fetch(this.queriesUrlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "X-CSRF-Token": csrfToken
      },
      body: `terms=${encodeURIComponent(query)}`
    })
  }

  #handleGlobalKeydown(event) {
    const modifier = isAppleDevice() ? event.metaKey : event.ctrlKey
    if (modifier && event.key === "k") {
      event.preventDefault()
      if (this.dialogTarget.open) {
        this.close()
      } else {
        this.open()
      }
    }
  }
}
