import { Controller } from "@hotwired/stimulus"

// Shows the chosen file name next to a custom "Choisir un fichier" button.
export default class extends Controller {
  static targets = ["name"]

  // Called when the hidden file input changes
  show(event) {
    const file = event.target.files[0]
    this.nameTarget.textContent = file ? file.name : "Aucun fichier choisi"
  }
}
