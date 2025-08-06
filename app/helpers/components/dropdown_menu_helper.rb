# frozen_string_literal: true

module Components
  module DropdownMenuHelper
    # Creates a dropdown menu component with a trigger button and content.
    #
    # @param trigger [String, ActiveSupport::SafeBuffer] The content of the trigger button
    # @param content [ActiveSupport::SafeBuffer] The content of the dropdown menu
    # @param width [String] Optional Tailwind width class for the dropdown menu (e.g., "w-48")
    # @param trigger_button_variant [Symbol] The style variant for the trigger button (:default, :outline, etc.)
    # @param trigger_button_options [Hash] Additional options to pass to the trigger button
    # @param data [Hash] Additional data attributes to add to the component container
    # @param options [Hash] Additional HTML attributes for the component container
    # @return [ActiveSupport::SafeBuffer] The rendered dropdown menu component
    def render_dropdown_menu(trigger:, content:, width: nil, trigger_button_variant: :outline, trigger_button_options: {}, data: {}, **options)
      content_classes = components_dropdown_menu_content_class
      content_classes += " #{width}" if width.present?

      render "components/ui/dropdown_menu", {
        trigger: trigger,
        trigger_button_variant: trigger_button_variant,
        trigger_button_options: trigger_button_options,
        content: content,
        content_options: { class: content_classes }
      }
    end

    private

      def components_dropdown_menu_base_class
        [
          "inline-block relative"
        ].join(" ")
      end

    def components_dropdown_menu_content_class
      [
        "w-56 origin-top-right rounded-md bg-white shadow-lg",
        "ring-1 ring-black/5 transition transition-discrete [--anchor-gap:--spacing(2)] focus:outline-hidden",
        "data-closed:scale-95 data-closed:transform data-closed:opacity-0",
        "data-enter:duration-100 data-enter:ease-out data-leave:duration-75 data-leave:ease-in"
      ].join(" ")
    end
  end
end
