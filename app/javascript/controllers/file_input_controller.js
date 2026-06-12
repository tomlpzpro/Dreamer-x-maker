import { Controller } from "@hotwired/stimulus"

// Shows the chosen file name (and an optional thumbnail) next to a custom
// "Choisir un fichier" button.
export default class extends Controller {
  static targets = ["name", "preview"]

  // Called when the hidden file input changes
  show(event) {
    const file = event.target.files[0]

    // Update the file name label
    if (this.hasNameTarget) {
      this.nameTarget.textContent = file ? file.name : "Aucun fichier choisi"
    }

    // Update the thumbnail preview, if there is one
    if (this.hasPreviewTarget) {
      if (file) {
        this.previewTarget.src = URL.createObjectURL(file)
        this.previewTarget.hidden = false
      } else {
        this.previewTarget.hidden = true
      }
    }
  }
}
