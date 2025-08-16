import { Controller } from "@hotwired/stimulus";

// Global theme controller - handles applying themes to the entire application
// Should be attached to the body or application layout level
export default class extends Controller {
  static values = {
    preference: String
  }

  connect() {
    // Cache MediaQueryList and a single bound handler so we can remove it later
    this.systemMediaQuery ||= window.matchMedia("(prefers-color-scheme: dark)");
    this.boundSystemThemeChange ||= this.handleSystemThemeChange.bind(this);

    this.systemMediaQuery.addEventListener("change", this.boundSystemThemeChange);

    // Apply initial theme
    this.applyTheme();
  }

  disconnect() {
    if (this.systemMediaQuery && this.boundSystemThemeChange) {
      this.systemMediaQuery.removeEventListener("change", this.boundSystemThemeChange);
    }

    this.boundSystemThemeChange = null;
    this.systemMediaQuery = null;
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
    const systemDarkModeMediaQueryList =
      this.systemMediaQuery || window.matchMedia("(prefers-color-scheme: dark)");
    return systemDarkModeMediaQueryList.matches;
  }
}