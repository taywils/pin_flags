import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pin-flags-navbar-burger"
export default class extends Controller {
  static targets = ["burger", "menu"]

  toggle() {
    this.burgerTarget.classList.toggle('is-active')
    this.menuTarget.classList.toggle('is-active')
  }
}