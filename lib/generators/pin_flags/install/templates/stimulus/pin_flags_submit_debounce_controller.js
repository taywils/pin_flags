import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pin-flags-submit-debounce"
export default class extends Controller {
  static targets = ["form"];
  static values = {
    delay: { type: Number, default: 500 },
  };

  activate(event) {
    event.preventDefault();

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, this.delayValue);
  }
}
