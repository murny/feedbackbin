import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form", "button" ]

  toggle(event) {
    event.preventDefault()
    this.formTarget.classList.toggle("display-none")
    this.buttonTarget.classList.toggle("display-none")
  }
}
