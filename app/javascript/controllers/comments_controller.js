import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.setupReplyForms()
  }

  toggleReplyForm(event) {
    const button = event.currentTarget
    const commentId = button.dataset.commentId
    const replyForm = document.getElementById(`reply-form-${commentId}`)
    
    if (replyForm) {
      if (replyForm.style.display === 'none') {
        // Hide all other reply forms first
        this.hideAllReplyForms()
        replyForm.style.display = 'block'
        button.textContent = 'Cancel Reply'
      } else {
        replyForm.style.display = 'none'
        button.textContent = 'Reply'
      }
    }
  }

  hideAllReplyForms() {
    const replyForms = document.querySelectorAll('.reply-form')
    const replyButtons = document.querySelectorAll('.reply-toggle')
    
    replyForms.forEach(form => form.style.display = 'none')
    replyButtons.forEach(button => button.textContent = 'Reply')
  }

  setupReplyForms() {
    // Hide all reply forms initially
    this.hideAllReplyForms()
  }
}
