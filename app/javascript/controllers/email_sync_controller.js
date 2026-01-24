import { Controller } from "@hotwired/stimulus"

// Syncs a shared email input to hidden fields in multiple forms
// Usage:
//   <div data-controller="email-sync">
//     <input type="email" data-email-sync-target="source">
//     <form data-action="submit->email-sync#sync">
//       <input type="hidden" name="email_address" data-email-sync-target="destination">
//     </form>
//   </div>
export default class extends Controller {
  static targets = ["source", "destination"]

  sync() {
    const email = this.sourceTarget.value
    this.destinationTargets.forEach(field => field.value = email)
  }
}
