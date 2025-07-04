// Use the global Stimulus Controller class
const { Controller } = window.Stimulus || {};

// Connects to data-controller="form-submit"
export default class extends Controller {
  connect() {
    console.log("Form submit controller connected!");
  }

  submit(event) {
    event.preventDefault();

    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.element.requestSubmit();
    }, 500);
  }
}
