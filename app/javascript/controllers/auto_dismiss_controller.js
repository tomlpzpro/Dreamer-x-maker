import { Controller } from "@hotwired/stimulus"

// Hides a flash alert on its own after a few seconds.
// Removing the "show" class lets Bootstrap fade it out, then we remove it.
export default class extends Controller {
  // How long to wait before hiding, in milliseconds (default: 5 seconds)
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  // Clear the timer if the alert is removed before the delay (ex: manual close)
  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    // Start Bootstrap's fade-out, then remove the alert from the page
    this.element.classList.remove("show")
    setTimeout(() => this.element.remove(), 200)
  }
}
