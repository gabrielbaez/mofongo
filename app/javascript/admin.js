// Import Bootstrap's JavaScript
import * as bootstrap from 'bootstrap'

// Initialize all tooltips
var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})

// Initialize all popovers
var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
  return new bootstrap.Popover(popoverTriggerEl)
})

document.addEventListener('DOMContentLoaded', function() {
  // Sidebar Toggle
  const showSidebar = document.getElementById('show-sidebar');
  const closeSidebar = document.getElementById('close-sidebar');
  const pageWrapper = document.querySelector('.page-wrapper');

  if (showSidebar) {
    showSidebar.addEventListener('click', function(e) {
      e.preventDefault();
      pageWrapper.classList.add('toggled');
    });
  }

  if (closeSidebar) {
    closeSidebar.addEventListener('click', function() {
      pageWrapper.classList.remove('toggled');
    });
  }

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
});
