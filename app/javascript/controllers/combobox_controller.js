import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    url: String,
    optionCreate: { type: String, default: "Add" },
    noResults: { type: String, default: "No results found" }
  }

  initialize() {
    this.load = this.load.bind(this)
  }

  connect() {
    if (this.element.nodeName === "INPUT") {
      this.tomSelect = new TomSelect(this.element, this.#inputSettings)
    } else {
      this.tomSelect = new TomSelect(this.element, this.#selectSettings)
    }
  }

  disconnect() {
    this.tomSelect.destroy()
  }

  async load(query, callback) {
    try {
      const response = await get(this.urlValue, { responseKind: "json", query: { q: query } })
      if (!response.ok) {
        callback()
        return
      }
      const jsonResponse = await response.json
      callback(jsonResponse)
    } catch (error) {
      console.error("Combobox load failed:", error)
      callback()
    }
  }

  get #inputSettings() {
    return {
      render: this.#render,
      load: this.#loadSetting,
      plugins: [ "remove_button" ],
      persist: false,
      createOnBlur: true,
      create: true
    }
  }

  get #selectSettings() {
    return {
      render: this.#render,
      load: this.#loadSetting,
      plugins: [ "remove_button" ]
    }
  }

  get #render() {
    return {
      option_create: (data, escape) => `<div class="create">${this.optionCreateValue} <b>${escape(data.input)}</b>…</div>`,
      no_results: () => `<div class="no-results">${this.noResultsValue}</div>`
    }
  }

  get #loadSetting() {
    return this.hasUrlValue && this.load
  }
}
