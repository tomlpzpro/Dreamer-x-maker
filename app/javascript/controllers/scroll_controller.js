import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll"
export default class extends Controller {
  static targets = ["message"]

  connect() {
    this.scrollToBottom()
  }

  messageTargetConnected() {
    this.scrollToBottom()
  }

  scrollToBottom() {
    this.element.scrollTo({ top: this.element.scrollHeight, behavior: "smooth" })
  }
}
