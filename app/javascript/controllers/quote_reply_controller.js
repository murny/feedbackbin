import { Controller } from "@hotwired/stimulus"

// Quotes a reply's text into the thread reply form
export default class extends Controller {
  static values = {
    text: String,
    formId: String
  }

  quote(event) {
    event.preventDefault()

    const formContainer = document.getElementById(this.formIdValue)
    if (!formContainer) return

    // Expand the reply form by clicking the trigger button
    const triggerButton = formContainer.querySelector("[data-reply-form-target='trigger']")
    if (triggerButton && !triggerButton.classList.contains("display-none")) {
      triggerButton.click()
    }

    // Wait for lexxy-editor to be ready, then insert quoted text
    this.#waitForEditor(formContainer, (lexxyEditor) => {
      this.#insertQuotedText(lexxyEditor, this.textValue)
      formContainer.scrollIntoView({ behavior: "smooth", block: "center" })
    })
  }

  #insertQuotedText(lexxyEditor, text) {
    const contentEl = lexxyEditor.querySelector(".lexxy-editor__content")
    if (!contentEl) return

    // Focus the editor
    contentEl.focus()

    // Click the Quote button to enable quote formatting first
    const quoteButton = lexxyEditor.querySelector('[data-command="insertQuoteBlock"]')
    if (quoteButton) {
      quoteButton.click()
    }

    // Insert the quoted text
    document.execCommand("insertText", false, text)

    // Move out of the quote block by inserting a new paragraph
    // Press Enter twice to exit the blockquote and start a new paragraph
    const selection = window.getSelection()
    if (selection.rangeCount > 0) {
      // Insert line breaks to exit quote and position cursor for response
      document.execCommand("insertParagraph", false)
      document.execCommand("insertParagraph", false)
    }

    contentEl.focus()
  }

  #waitForEditor(container, callback, attempts = 0) {
    const maxAttempts = 20
    const lexxyEditor = container.querySelector("lexxy-editor")

    if (lexxyEditor && lexxyEditor.editor) {
      callback(lexxyEditor)
    } else if (attempts < maxAttempts) {
      setTimeout(() => this.#waitForEditor(container, callback, attempts + 1), 50)
    }
  }
}
