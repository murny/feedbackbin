import { Controller } from "@hotwired/stimulus";

// Global theme controller - handles applying themes to the entire application
// Should be attached to the body or application layout level
export default class extends Controller {
  static values = {
    preference: String,
    theme: String,
    accentColor: String
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

  themeValueChanged() {
    this.applyTheme();
  }

  accentColorValueChanged() {
    this.applyAccentColor();
  }

  handleSystemThemeChange() {
    // Only react to system changes if user has "system" preference
    if (this.preferenceValue === "system" || this.themeValue === "system") {
      this.applyTheme();
    }
  }

  applyTheme() {
    // Determine which theme to apply
    const theme = this.themeValue || "system";

    if (theme === "system") {
      // Use system preference to choose light or dark
      const isDark = this.systemInDarkMode;
      const effectiveTheme = isDark ? "dark" : "light";
      document.documentElement.setAttribute("data-theme", effectiveTheme);
      document.documentElement.classList.toggle("dark", isDark);
    } else {
      // Use the specified theme (light, dark, purple, navy)
      document.documentElement.setAttribute("data-theme", theme);

      // Also set the .dark class for backward compatibility if theme is dark, purple, or navy
      const isDark = ["dark", "purple", "navy"].includes(theme);
      document.documentElement.classList.toggle("dark", isDark);
    }

    // Apply accent color as well
    this.applyAccentColor();
  }

  applyAccentColor() {
    const accentColor = this.accentColorValue;

    if (accentColor) {
      // Convert hex color to oklch for CSS variable
      // For now, just set it as a custom property
      document.documentElement.style.setProperty("--custom-accent", accentColor);
      document.documentElement.setAttribute("data-accent-color", "custom");
    } else {
      document.documentElement.style.removeProperty("--custom-accent");
      document.documentElement.removeAttribute("data-accent-color");
    }
  }

  get systemInDarkMode() {
    const systemDarkModeMediaQueryList =
      this.systemMediaQuery || window.matchMedia("(prefers-color-scheme: dark)");
    return systemDarkModeMediaQueryList.matches;
  }
}