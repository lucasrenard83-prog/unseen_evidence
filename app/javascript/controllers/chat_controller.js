import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages"]

  connect() {
    this.scrollToBottom()
    this.observeNewMessages()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  observeNewMessages() {
    if (this.hasMessagesTarget) {
      const observer = new MutationObserver(() => {
        this.scrollToBottom()
      })
      observer.observe(this.messagesTarget, { childList: true, subtree: true })
    }
  }
}
