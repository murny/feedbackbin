# frozen_string_literal: true

module FeedbackbinElements
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
      base_classes = components_dropdown_menu_base_class
      content_classes = components_dropdown_menu_content_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      # Set up the Stimulus controller data attributes
      options[:data] ||= {}
      options[:data][:controller] = "dropdown"
      options[:data][:action] = "click@window->dropdown#hide touchstart@window->dropdown#hide keydown.up->dropdown#previousItem keydown.down->dropdown#nextItem keydown.esc->dropdown#hide"

      # Merge additional data attributes
      options[:data].merge!(data)

      # Create content options
      content_options = { class: content_classes }
      content_options[:class] += " #{options.delete(:content_class)}" if options[:content_class].present?
      content_options[:class] += " #{width}" if width.present?

      # Delete content_class from options since we've already used it
      options.delete(:content_class)

      # Set up button options
      trigger_button_options[:variant] = trigger_button_variant
      trigger_button_options[:data] ||= {}
      trigger_button_options[:data][:action] = "dropdown#toggle:stop"
      trigger_button_options[:data][:dropdown_target] = "button"

      render "feedbackbin_elements/components/dropdown_menu", {
        trigger: trigger,
        trigger_button_options: trigger_button_options,
        content: content,
        width: width,
        content_options: content_options,
        options: options
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
          "hidden absolute z-50 min-w-[8rem] overflow-hidden",
          "rounded-md border bg-popover text-popover-foreground p-1 shadow-md",
          # Animations
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          "origin-[var(--radix-dropdown-menu-content-transform-origin)]"
        ].join(" ")
      end
  end
end
