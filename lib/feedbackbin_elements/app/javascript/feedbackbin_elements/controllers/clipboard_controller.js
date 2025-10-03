import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  copy(event) {
    event.preventDefault()

    const text = this.contentTarget.textContent
    navigator.clipboard.writeText(text)

    // Show a temporary success message
    const button = event.currentTarget
    const originalHTML = button.innerHTML

    button.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500">
        <polyline points="20 6 9 17 4 12"></polyline>
      </svg>
    `

    setTimeout(() => {
      button.innerHTML = originalHTML
    }, 2000)
  }
}
