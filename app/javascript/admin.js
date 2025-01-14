// Import Bootstrap's JavaScript
import * as bootstrap from 'bootstrap'

// Initialize all tooltips
var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})

// Initialize all popovers
const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
const popoverList = [...popoverTriggerList].map(popoverTriggerEl => {
  return new bootstrap.Popover(popoverTriggerEl)
})

// Initialize sidebar state (hidden by default)
function initializeSidebar() {
  const showSidebar = document.getElementById('show-sidebar');
  const closeSidebar = document.getElementById('close-sidebar');
  const pageWrapper = document.querySelector('.page-wrapper');

  if (!showSidebar || !closeSidebar || !pageWrapper) {
    return;
  }

  pageWrapper.classList.remove('toggled');

  showSidebar.addEventListener('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    pageWrapper.classList.add('toggled');
    console.log('Toggled class added');
  });

  closeSidebar.addEventListener('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    pageWrapper.classList.remove('toggled');
    console.log('Toggled class removed');
  });
}

// Initialize sidebar when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeSidebar);
} else {
  initializeSidebar();
}

// Also initialize when Turbo loads a new page
document.addEventListener('turbo:load', initializeSidebar);

// Watch for changes to the DOM in case the sidebar is added dynamically
const observer = new MutationObserver(function(mutations) {
  mutations.forEach(function(mutation) {
    if (mutation.addedNodes.length) {
      initializeSidebar();
    }
  });
});

observer.observe(document.documentElement, {
  childList: true,
  subtree: true
});

// Sidebar Dropdowns
const dropdowns = document.querySelectorAll('.sidebar-dropdown > a');
dropdowns.forEach(dropdown => {
  dropdown.addEventListener('click', function(e) {
    e.preventDefault();
    const parent = this.parentElement;
    const submenu = parent.querySelector('.sidebar-submenu');
    
    // Close other dropdowns
    const otherDropdowns = document.querySelectorAll('.sidebar-dropdown');
    otherDropdowns.forEach(other => {
      if (other !== parent && other.classList.contains('active')) {
        other.classList.remove('active');
        other.querySelector('.sidebar-submenu').style.display = 'none';
      }
    });

    // Toggle current dropdown
    parent.classList.toggle('active');
    if (submenu) {
      if (submenu.style.display === 'block') {
        submenu.style.display = 'none';
      } else {
        submenu.style.display = 'block';
      }
    }
  });
});