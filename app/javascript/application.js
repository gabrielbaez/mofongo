// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "./controllers"
import * as bootstrap from "bootstrap"

// Initialize Bootstrap tooltips and popovers
document.addEventListener("turbo:load", () => {
  // Initialize Bootstrap tooltips
  const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize Bootstrap popovers
  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
})
