// Mobile sidebar functionality
document.addEventListener('DOMContentLoaded', function() {
  const sidebarToggle = document.getElementById('sidebar-toggle');
  const sidebarCloseBtn = document.getElementById('sidebar-close-btn');
  const sidebar = document.getElementById('logo-sidebar');
  const backdrop = document.getElementById('sidebar-backdrop');

  function openSidebar() {
    if (!sidebar || !backdrop) return;

    sidebar.classList.remove('-translate-x-full');
    backdrop.classList.remove('hidden');
    document.body.classList.add('overflow-hidden');

    // Update ARIA attributes
    if (sidebarToggle) {
      sidebarToggle.setAttribute('aria-expanded', 'true');
    }
  }

  function closeSidebar() {
    if (!sidebar || !backdrop) return;

    sidebar.classList.add('-translate-x-full');
    backdrop.classList.add('hidden');
    document.body.classList.remove('overflow-hidden');

    // Update ARIA attributes
    if (sidebarToggle) {
      sidebarToggle.setAttribute('aria-expanded', 'false');
    }
  }

  // Open sidebar when toggle is clicked
  if (sidebarToggle) {
    sidebarToggle.addEventListener('click', openSidebar);
  }

  // Close sidebar when close button is clicked
  if (sidebarCloseBtn) {
    sidebarCloseBtn.addEventListener('click', closeSidebar);
  }

  // Close sidebar when backdrop is clicked
  if (backdrop) {
    backdrop.addEventListener('click', closeSidebar);
  }

  // Close sidebar when escape key is pressed
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && backdrop && !backdrop.classList.contains('hidden')) {
      closeSidebar();
    }
  });

  // Close sidebar on window resize to large screen
  window.addEventListener('resize', function() {
    if (window.innerWidth >= 1024) { // lg breakpoint
      closeSidebar();
    }
  });

  // Sidebar submenu toggle functionality
  const sidebarToggleBtns = document.querySelectorAll('.sidebar-toggle-btn');

  sidebarToggleBtns.forEach(function(btn) {
    btn.addEventListener('click', function() {
      const targetId = this.getAttribute('data-target');
      const submenu = document.getElementById(targetId);
      const chevron = this.querySelector('.sidebar-chevron');
      const isExpanded = this.getAttribute('aria-expanded') === 'true';

      if (submenu) {
        if (isExpanded) {
          // Collapse
          submenu.classList.add('hidden');
          if (chevron) {
            chevron.classList.remove('rotate-90');
          }
          this.setAttribute('aria-expanded', 'false');
        } else {
          // Expand
          submenu.classList.remove('hidden');
          if (chevron) {
            chevron.classList.add('rotate-90');
          }
          this.setAttribute('aria-expanded', 'true');
        }
      }
    });
  });
});