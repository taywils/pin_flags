import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="pin-flags-file-size"
export default class extends Controller {
  static targets = ["input", "error", "fileName"];
  static values = { max: Number };

  validate() {
    const fileInput = this.inputTarget;
    const errorElement = this.errorTarget;

    if (this.hasInputTarget && this.hasErrorTarget) {
      this.#updateFileName();
      return this.#checkFileSize(fileInput, errorElement);
    }
  }

  #updateFileName() {
    const fileInput = this.inputTarget;
    const fileName = fileInput.files[0]?.name || 'No file selected';
    
    // Try to find file name element via target first, then fallback to DOM search
    let fileNameElement = this.hasFileNameTarget ? this.fileNameTarget : null;
    
    if (!fileNameElement) {
      fileNameElement = fileInput.closest('.file')?.querySelector('.file-name');
    }
    
    if (fileNameElement) {
      fileNameElement.textContent = fileName;
    }
  }

  #checkFileSize(fileInput, errorElement) {
    if (fileInput.files.length > 0) {
      const fileSize = fileInput.files[0].size;

      if (fileSize > this.maxValue) {
        errorElement.classList.remove("is-hidden");
        fileInput.classList.add("is-danger");
        fileInput.value = ""; // Clear the input
        this.#updateFileName(); // Update file name after clearing
        return false;
      }
    }

    errorElement.classList.add("is-hidden");
    fileInput.classList.remove("is-danger");
    return true;
  }
}
