import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="pin-flags-form-submit"
export default class extends Controller {
  submit(event) {
    event.preventDefault();

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 500);
  }
}