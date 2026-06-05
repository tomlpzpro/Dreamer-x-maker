import { Controller } from "@hotwired/stimulus"

// Places a chat message on the right ("from me") or on the left ("from the other
// person") by comparing the message author with the logged-in user.
export default class extends Controller {
  // The id of the user who wrote this message
  static values = { userId: Number }

  connect() {
    // Read the logged-in user id from the meta tag in the page head
    const meta = document.querySelector('meta[name="current-user-id"]')
    const myId = meta ? Number(meta.content) : null

    // My own messages go on the right, the other person's go on the left
    if (this.userIdValue === myId) {
      this.element.classList.add("from-user")
    } else {
      this.element.classList.add("from-other")
    }
  }
}
