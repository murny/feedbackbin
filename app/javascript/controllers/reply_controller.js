import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "body", "link", "author" ]
  static outlets = [ "composer" ]

  connect() {
    this.#formatLinkTargets()
  }

  reply() {
    const content = `<blockquote>${this.#bodyContent}</blockquote><cite>${this.authorTarget.innerHTML} ${this.#linkToOriginal}</cite><br>`
    this.composerOutlet.replaceMessageContent(content)
  }

  #formatLinkTargets() {
    this.bodyTarget.querySelectorAll("a").forEach(link => {
      const sameDomain = link.href.startsWith(window.location.origin)
      link.target = sameDomain ? "_top" : "_blank"
    })
  }

  get #bodyContent() {
    return this.#stripMentionAttachments(this.bodyTarget.querySelector(".trix-content"))
  }

  #stripMentionAttachments(node) {
    node.querySelectorAll(".mention").forEach(mention => mention.outerHTML = mention.textContent.trim())
    return node.innerHTML
  }

  get #linkToOriginal() {
    return `<a href="${this.linkTarget.href}">#</a>`
  }
}