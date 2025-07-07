import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pin-flags-js-modal-trigger"
export default class extends Controller {
  static targets = ["modal"]
  static values = { modalId: String }

  connect() {
    // Listen for ESC key globally
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("keydown", this.boundCloseOnEscape)
  }

  disconnect() {
    // Clean up event listener
    document.removeEventListener("keydown", this.boundCloseOnEscape)
  }

  // Action to open a specific modal
  open(event) {
    event.preventDefault()
    const modalId = this.modalIdValue || event.currentTarget.dataset.target
    const modal = document.getElementById(modalId)
    
    if (modal) {
      this.openModal(modal)
    }
  }

  // Action to close the current modal
  close(event) {
    event.preventDefault()
    const modal = event.currentTarget.closest('.modal')
    
    if (modal) {
      this.closeModal(modal)
    }
  }

  // Close all modals
  closeAll() {
    const modals = document.querySelectorAll('.modal')
    modals.forEach(modal => this.closeModal(modal))
  }

  // Close on ESC key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.closeAll()
    }
  }

  // Private methods
  openModal(modal) {
    modal.classList.add('is-active')
  }

  closeModal(modal) {
    modal.classList.remove('is-active')
  }
}