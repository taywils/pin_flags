import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pin-flags-input-cursor"
export default class extends Controller {
  connect() {
    this.moveCursorToEnd()
  }

  moveCursorToEnd() {
    const input = this.element
    if (input.value && input.value.length > 0) {
      input.setSelectionRange(input.value.length, input.value.length)
    }
  }
}
