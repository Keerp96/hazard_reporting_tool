import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  highlight() {
    const value = this.selectTarget.value
    this.selectTarget.classList.remove("border-success", "border-warning", "border-danger")

    switch(value) {
      case "low":
        this.selectTarget.classList.add("border-success")
        break
      case "medium":
        this.selectTarget.classList.add("border-warning")
        break
      case "high":
      case "critical":
        this.selectTarget.classList.add("border-danger")
        break
    }
  }
}
