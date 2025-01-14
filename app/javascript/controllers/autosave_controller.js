import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status"]
  static values = {
    url: String,
    interval: { type: Number, default: 30000 } // 30 seconds
  }
  
  connect() {
    this.autosaveInterval = setInterval(() => {
      this.save()
    }, this.intervalValue)
  }
  
  disconnect() {
    if (this.autosaveInterval) {
      clearInterval(this.autosaveInterval)
    }
  }
  
  async save() {
    const form = this.formTarget
    const formData = new FormData(form)
    
    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        this.showStatus("Draft saved")
        
        // Update the form action if this is a new post
        if (data.id && form.action.includes("/blog_posts")) {
          form.action = form.action.replace("/blog_posts", `/blog_posts/${data.id}`)
          form.querySelector('input[name="_method"]')?.remove()
          const methodInput = document.createElement('input')
          methodInput.type = 'hidden'
          methodInput.name = '_method'
          methodInput.value = 'patch'
          form.appendChild(methodInput)
        }
      } else {
        this.showStatus("Error saving draft", true)
      }
    } catch (error) {
      console.error("Autosave error:", error)
      this.showStatus("Error saving draft", true)
    }
  }
  
  showStatus(message, isError = false) {
    const status = this.statusTarget
    status.textContent = message
    status.classList.toggle("text-danger", isError)
    status.classList.toggle("text-success", !isError)
    status.classList.remove("d-none")
    
    setTimeout(() => {
      status.classList.add("d-none")
    }, 3000)
  }
}
