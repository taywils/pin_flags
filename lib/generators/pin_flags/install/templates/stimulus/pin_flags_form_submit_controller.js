import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pin-flags-form-submit"
export default class extends Controller {
  connect() {
    console.log("Pin Flags form submit controller connected!");
  }

  submit(event) {
    event.preventDefault();

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 500);
  }
}