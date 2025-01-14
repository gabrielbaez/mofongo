// Import Bootstrap's JavaScript
import * as Popper from "@popperjs/core"
import * as bootstrap from "bootstrap"

// Initialize when the DOM is loaded
function initializeAdmin() {
  console.log('Admin JS initializing...');
  
  try {
    // Initialize all tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    tooltipTriggerList.forEach(tooltipTriggerEl => {
      new bootstrap.Tooltip(tooltipTriggerEl)
    });

    // Initialize all popovers
    const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
    popoverTriggerList.forEach(popoverTriggerEl => {
      new bootstrap.Popover(popoverTriggerEl)
    });

    console.log('Admin JS initialization completed');
  } catch (error) {
    console.error('Error initializing admin JS:', error);
  }
}

// Initialize on Turbo load
document.addEventListener("turbo:load", initializeAdmin);

// Also initialize if the document is already loaded
if (document.readyState === 'complete') {
  initializeAdmin();
}