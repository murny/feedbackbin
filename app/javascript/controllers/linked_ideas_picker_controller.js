import { Controller } from "@hotwired/stimulus"
import { debounce } from "helpers/timing_helpers"

export default class extends Controller {
  static targets = ["input", "frame", "chips"]
  static values = {
    url: String,
    minLength: { type: Number, default: 2 }
  }

  initialize() {
    this.search = debounce(this.#performSearch.bind(this), 300)
  }

  add(event) {
    const id = String(event.params.id)
    const title = event.params.title

    if (this.#chipExistsFor(id)) {
      this.#resetSearch()
      return
    }

    const chip = document.createElement("span")
    chip.className = "badge"
    chip.setAttribute("data-linked-ideas-picker-chip", "")

    const titleNode = document.createTextNode(`${title} `)
    chip.appendChild(titleNode)

    const remove = document.createElement("button")
    remove.type = "button"
    remove.className = "linked-ideas-picker__remove"
    remove.setAttribute("data-action", "click->linked-ideas-picker#remove")
    remove.textContent = "×"
    chip.appendChild(remove)

    const hidden = document.createElement("input")
    hidden.type = "hidden"
    hidden.name = "changelog[idea_ids][]"
    hidden.value = id
    chip.appendChild(hidden)

    this.chipsTarget.appendChild(chip)

    this.#resetSearch()
  }

  remove(event) {
    const chip = event.currentTarget.closest("[data-linked-ideas-picker-chip]")
    if (chip) chip.remove()
  }

  #performSearch() {
    const filter = this.inputTarget.value.trim()
    if (filter.length < this.minLengthValue) {
      this.frameTarget.removeAttribute("src")
      this.frameTarget.innerHTML = ""
      return
    }
    const url = new URL(this.urlValue, window.location.origin)
    url.searchParams.set("filter", filter)
    this.frameTarget.src = url.toString()
  }

  #chipExistsFor(id) {
    return this.chipsTarget.querySelector(
      `input[type="hidden"][name="changelog[idea_ids][]"][value="${id}"]`
    ) !== null
  }

  #resetSearch() {
    this.inputTarget.value = ""
    this.frameTarget.removeAttribute("src")
    this.frameTarget.innerHTML = ""
  }
}
