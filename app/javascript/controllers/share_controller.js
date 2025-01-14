import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

export default class extends Controller {
  static targets = ["toast"]
  static values = {
    url: String,
    title: String,
    description: String
  }
  
  connect() {
    this.toast = new Toast(this.toastTarget)
  }
  
  async copyLink() {
    try {
      await navigator.clipboard.writeText(this.urlValue)
      this.toast.show()
    } catch (err) {
      console.error("Failed to copy link:", err)
    }
  }
  
  shareTwitter() {
    const url = new URL("https://twitter.com/intent/tweet")
    url.searchParams.set("url", this.urlValue)
    url.searchParams.set("text", this.titleValue)
    
    this.openShareWindow(url)
  }
  
  shareFacebook() {
    const url = new URL("https://www.facebook.com/sharer/sharer.php")
    url.searchParams.set("u", this.urlValue)
    
    this.openShareWindow(url)
  }
  
  shareLinkedIn() {
    const url = new URL("https://www.linkedin.com/shareArticle")
    url.searchParams.set("url", this.urlValue)
    url.searchParams.set("title", this.titleValue)
    url.searchParams.set("summary", this.descriptionValue)
    url.searchParams.set("mini", "true")
    
    this.openShareWindow(url)
  }
  
  shareEmail() {
    const url = new URL("mailto:")
    url.searchParams.set("subject", this.titleValue)
    url.searchParams.set("body", `${this.descriptionValue}\n\n${this.urlValue}`)
    
    window.location.href = url.toString()
  }
  
  openShareWindow(url) {
    window.open(
      url.toString(),
      "share-dialog",
      "width=600,height=400,location=0,menubar=0"
    )
  }
}
