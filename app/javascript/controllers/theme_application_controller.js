import { Controller } from "@hotwired/stimulus";

// Global theme controller - handles applying themes to the entire application
// Should be attached to the body or application layout level
export default class extends Controller {
  static values = {
    preference: String
  }

  connect() {
    // Listen for system theme changes
    window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", this.handleSystemThemeChange.bind(this));
    
    // Apply initial theme
    this.applyTheme();
  }

  disconnect() {
    window.matchMedia("(prefers-color-scheme: dark)").removeEventListener("change", this.handleSystemThemeChange.bind(this));
  }

  preferenceValueChanged() {
    this.applyTheme();
  }

  handleSystemThemeChange() {
    // Only react to system changes if user has "system" preference
    if (this.preferenceValue === "system") {
      this.applyTheme();
    }
  }

  applyTheme() {
    const isDark = this.preferenceValue === "dark" || 
                   (this.preferenceValue === "system" && this.systemInDarkMode);
    document.documentElement.classList.toggle("dark", isDark);
  }

  get systemInDarkMode() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches;
  }
}