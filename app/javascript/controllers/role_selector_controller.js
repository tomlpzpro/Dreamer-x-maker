import { Controller } from "@hotwired/stimulus"

// Lets the visitor choose to sign up as a Dreamer or a Maker.
// Clicking a button fills the hidden role field, highlights the chosen button,
// and shows the maker-only fields (and makes them required) when "maker" is picked.
export default class extends Controller {
  static targets = ["input", "dreamerButton", "makerButton", "makerFields", "skills"]

  connect() {
    // Highlight the button matching the role already chosen (if any)
    this.refresh()
  }

  // Called when a role button is clicked (role is read from its data-role)
  choose(event) {
    this.inputTarget.value = event.currentTarget.dataset.role
    this.refresh()
  }

  // Update the buttons and the maker fields to match the current role
  refresh() {
    const role = this.inputTarget.value
    const isMaker = role === "maker"

    // Highlight the active button
    this.dreamerButtonTarget.classList.toggle("is-active", role === "dreamer")
    this.makerButtonTarget.classList.toggle("is-active", isMaker)

    // Show the maker fields and require the skills only for a maker
    this.makerFieldsTarget.hidden = !isMaker
    this.skillsTarget.required = isMaker
  }
}
