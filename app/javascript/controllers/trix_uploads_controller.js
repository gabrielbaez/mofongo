import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("trix-attachment-add", this.uploadAttachment)
  }

  disconnect() {
    this.element.removeEventListener("trix-attachment-add", this.uploadAttachment)
  }

  uploadAttachment = async (event) => {
    const attachment = event.attachment
    if (attachment.file) {
      try {
        const formData = new FormData()
        formData.append("blob[filename]", attachment.file.name)
        formData.append("blob[content_type]", attachment.file.type)
        formData.append("blob[byte_size]", attachment.file.size)
        formData.append("blob[checksum]", await this.calculateChecksum(attachment.file))

        const response = await fetch("/admin/direct_uploads", {
          method: "POST",
          headers: {
            "Accept": "application/json",
            "X-CSRF-Token": this.getMetaValue("csrf-token")
          },
          body: formData,
          credentials: "same-origin"
        })

        if (response.ok) {
          const upload = await response.json()
          const uploadFormData = new FormData()
          uploadFormData.append("file", attachment.file)

          const uploadResponse = await fetch(upload.direct_upload.url, {
            method: "PUT",
            headers: upload.direct_upload.headers,
            body: attachment.file
          })

          if (uploadResponse.ok) {
            attachment.setAttributes({
              url: this.createBlobUrl(upload.signed_id),
              href: this.createBlobUrl(upload.signed_id)
            })
          }
        }
      } catch (error) {
        console.error("Error uploading file:", error)
      }
    }
  }

  calculateChecksum = (file) => {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = (event) => {
        const data = event.target.result
        resolve(btoa(data))
      }
      reader.onerror = () => reject(reader.error)
      reader.readAsBinaryString(file)
    })
  }

  getMetaValue = (name) => {
    const element = document.head.querySelector(`meta[name="${name}"]`)
    return element.getAttribute("content")
  }

  createBlobUrl = (signedId) => {
    return `/rails/active_storage/blobs/${signedId}`
  }
}
