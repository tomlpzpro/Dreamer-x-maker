import { Controller } from "@hotwired/stimulus"

// Plays a full-screen color flash, then submits the form.
// Used on the project page when a maker matches a project ("blue")
// or says the project is not for him ("orange").
export default class extends Controller {
  // The color of the flash: "blue" for match, "orange" for dismiss
  static values = { color: String }

  // Called when the maker clicks the button
  go(event) {
    // Stop the form from submitting right away: we want the animation first
    event.preventDefault()

    // Create a full-screen colored layer on top of the page
    const overlay = document.createElement("div")
    // Give it the base class and the chosen color class
    overlay.classList.add("flash-overlay", `flash-${this.colorValue}`)
    // Add the layer to the page
    document.body.appendChild(overlay)

    // Wait one frame, then make it visible so the fade-in animation runs
    requestAnimationFrame(() => {
      overlay.classList.add("is-visible")
    })

    // After the animation, actually submit the form (match or dismiss)
    setTimeout(() => {
      this.element.requestSubmit()
    }, 500)
  }
}
