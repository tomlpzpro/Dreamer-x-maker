import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showLoading() {
    Swal.fire({
      title: "Génération en cours...",
      text: "Votre visuel est en cours de création, cela peut prendre jusqu'à 40 secondes. Vous pouvez continuer à naviguer !",
      icon: "info",
      showConfirmButton: false,
      allowOutsideClick: false,
      didOpen: () => {
        Swal.showLoading()
      }
    })
  }
}
