import { Controller } from "@hotwired/stimulus"
import { Modal, Toast } from "bootstrap"

export default class extends Controller {
  static targets = ["modalTitle", "modalImage", "modalDescription", "modalCopyButton", "toast"]
  
  connect() {
    this.modal = new Modal(document.getElementById("imagePreviewModal"))
    this.toast = new Toast(this.toastTarget)
  }
  
  showImage(event) {
    const { url, title, description } = event.currentTarget.dataset.galleryUrlParam
    
    this.modalTitleTarget.textContent = title
    this.modalImageTarget.src = url
    this.modalDescriptionTarget.textContent = description
    this.modalCopyButtonTarget.dataset.galleryUrlParam = url
    
    this.modal.show()
  }
  
  async copyUrl(event) {
    const url = event.currentTarget.dataset.galleryUrlParam
    
    try {
      await navigator.clipboard.writeText(url)
      this.toast.show()
    } catch (err) {
      console.error("Failed to copy URL:", err)
    }
  }
}
