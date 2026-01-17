import { Controller } from "@hotwired/stimulus"

// Tagging controller for managing idea tags
// Allows users to add, remove, and filter tags with keyboard support
//
// Usage:
//   <div data-controller="tagging" data-tagging-idea-id-value="123">
//     <input data-tagging-target="input" data-action="input->tagging#filterTags" />
//     <div data-tagging-target="tagsList">...</div>
//   </div>
export default class extends Controller {
  static targets = ["input", "tagsList", "tagItem"]
  static values = {
    ideaId: Number
  }

  connect() {
    // Bind keyboard shortcut 't' to open menu when not focused on input
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  // Handle global 't' keyboard shortcut
  handleKeydown(event) {
    // Only trigger if 't' is pressed and not in an input/textarea
    if (event.key === "t" && !this.isInputFocused(event.target)) {
      event.preventDefault()
      this.openMenu()
    }
  }

  // Check if the target is an input element
  isInputFocused(element) {
    return element.tagName === "INPUT" || element.tagName === "TEXTAREA" || element.isContentEditable
  }

  // Open the tagging menu and focus the input
  openMenu() {
    if (this.hasInputTarget) {
      this.inputTarget.focus()
    }
  }

  // Filter tags based on input value
  filterTags(event) {
    const query = event.target.value.toLowerCase().trim()

    this.tagItemTargets.forEach(item => {
      const tagTitle = item.dataset.tagTitle || ""
      const matches = tagTitle.includes(query)
      item.classList.toggle("hidden", !matches)
    })
  }

  // Toggle tag assignment
  async toggleTag(event) {
    event.preventDefault()
    const tagItem = event.currentTarget
    const tagId = tagItem.dataset.tagId
    const tagTitle = tagItem.dataset.tagTitle
    const isAssigned = tagItem.querySelector('[data-lucide="check"]') !== null

    try {
      if (isAssigned) {
        // Unassign tag - find the tagging and delete it
        await this.unassignTag(tagId)
      } else {
        // Assign tag
        await this.assignTag(tagTitle)
      }
    } catch (error) {
      console.error("Error toggling tag:", error)
    }
  }

  // Create a new tag from input
  async createTag(event) {
    event.preventDefault()
    const tagTitle = this.inputTarget.value.trim()

    if (!tagTitle) return

    // Check if tag already exists
    const existingTag = this.tagItemTargets.find(item =>
      item.dataset.tagTitle === tagTitle.toLowerCase()
    )

    if (existingTag) {
      // If exists, click it to toggle
      existingTag.click()
    } else {
      // Create new tag
      await this.assignTag(tagTitle)
    }

    // Clear input
    this.inputTarget.value = ""
    this.filterTags({ target: this.inputTarget })
  }

  // Assign a tag to the idea
  async assignTag(tagTitle) {
    const formData = new FormData()
    formData.append("tagging[title]", tagTitle)

    await fetch(`/ideas/${this.ideaIdValue}/taggings`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: formData
    })
  }

  // Unassign a tag from the idea
  async unassignTag(tagId) {
    // We need to find the tagging ID - this is a bit tricky
    // For now, we'll need to add the tagging ID to the data attribute
    // Or we can make a different approach - let's use the tag ID to find it
    const response = await fetch(`/ideas/${this.ideaIdValue}/taggings/${tagId}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      }
    })
  }

  // Get CSRF token for requests
  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
