// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

// Initialize Bootstrap components
const initBootstrap = () => {
  // Enable all Bootstrap dropdowns
  const dropdownElementList = document.querySelectorAll('.dropdown-toggle')
  dropdownElementList.forEach(dropdownToggle => {
    new bootstrap.Dropdown(dropdownToggle)
  })

  // Enable all Bootstrap collapses
  const collapseElementList = document.querySelectorAll('.collapse')
  collapseElementList.forEach(collapseEl => {
    new bootstrap.Collapse(collapseEl, {
      toggle: false
    })
  })
}

// Initialize on page load
document.addEventListener('turbo:load', initBootstrap)
// Re-initialize after any Turbo navigation
document.addEventListener('turbo:render', initBootstrap)
