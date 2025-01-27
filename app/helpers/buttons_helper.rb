module ButtonsHelper
  # Generates button tags for Turbo disable with
  # Preserve opacity-25 opacity-75 during purge
  def button_text(text = nil, disable_with: t("processing"), &block)
    text = capture(&block) if block

    tag.span(text, class: "when-enabled") +
      tag.span(class: "when-disabled") do
        <<~ICON.html_safe + disable_with
          <svg class="animate-spin inline-block mr-2 h-4 w-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
        ICON
      end
  end
end
