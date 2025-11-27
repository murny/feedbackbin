# frozen_string_literal: true

# Configure Lookbook for ViewComponent previews
if defined?(Lookbook)
  Lookbook.configure do |config|
    # Use a minimal layout for component previews (avoids navbar/footer partials)
    config.preview_layout = "lookbook"

    # Add theme switcher in Lookbook UI
    config.preview_display_options = {
      theme: [ "light", "dark" ]
    }
  end
end
