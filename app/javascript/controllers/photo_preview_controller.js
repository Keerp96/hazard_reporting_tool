import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    if (file.size > 5 * 1024 * 1024) {
      alert("File size must be less than 5MB")
      this.inputTarget.value = ""
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      this.containerTarget.innerHTML = `<img src="${e.target.result}" class="img-thumbnail" style="max-height: 200px;">`
    }
    reader.readAsDataURL(file)
  }
}
