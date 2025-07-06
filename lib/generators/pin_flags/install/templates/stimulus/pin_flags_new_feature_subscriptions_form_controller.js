import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pin-flags-new-feature-subscriptions-form"
export default class extends Controller {
  static targets = ["container", "textTemplate", "textareaTemplate"];

  toggle(event) {
    this.containerTarget.innerHTML = ""; // Clear the container

    const template = event.target.checked
      ? this.textareaTemplateTarget
      : this.textTemplateTarget;
    const clone = template.content.firstElementChild.cloneNode(true);

    this.containerTarget.appendChild(clone);
  }
}
