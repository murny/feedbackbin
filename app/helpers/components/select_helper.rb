# frozen_string_literal: true

module Components
  module SelectHelper
    # Custom Select Component using Tailwind Elements
    # Usage:
    #   <%= render_select(
    #     value: current_value,
    #     placeholder: "Select an option",
    #     options: [
    #       { value: "1", text: "Option 1", href: "/path/1" },
    #       { value: "2", text: "Option 2", href: "/path/2" }
    #     ],
    #     class: "w-48"
    #   ) %>

    # Set defaults
    # options ||= []
    # placeholder ||= "Select..."
    # css_class = ["inline-block", css_class].compact.join(" ")

    # Find selected option
    # selected_option = options.find { |opt| opt[:value].to_s == value.to_s }
    # selected_text = selected_option ? selected_option[:text] : placeholder



    # Creates a custom select component using Tailwind Elements.
    #
    # @param value [String, Integer] The currently selected value
    # @param options [Array<Hash>] Array of option hashes with :value, :text, and optional :href keys
    # @param placeholder [String] Placeholder text when no option is selected
    # @param css_class [String] Additional CSS classes for the select component
    # @param html_options [Hash] Additional HTML attributes for the component container
    # @return [ActiveSupport::SafeBuffer] The rendered select component
    def render_select(value: nil, options: [], placeholder: "Select...", css_class: nil, **html_options)
      render "components/ui/select", {
        value: value,
        options: options,
        placeholder: placeholder,
        css_class: css_class
      }
    end
  end
end
