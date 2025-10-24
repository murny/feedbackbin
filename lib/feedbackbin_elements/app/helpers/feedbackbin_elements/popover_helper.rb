# frozen_string_literal: true

module FeedbackbinElements
  module PopoverHelper
    def render_popover(trigger:, content:, align: :center, side: :bottom, side_offset: 4, width: nil, dismiss_after: nil, trigger_on: :hover, data: {}, **options)
      base_classes = components_popover_base_class
      content_classes = components_popover_content_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      # Set up the Stimulus controller data attributes
      options[:data] ||= {}
      options[:data][:controller] = "popover"
      options[:data][:popover_dismiss_after_value] = dismiss_after if dismiss_after.present?

      # Set up action based on trigger_on option
      action = case trigger_on
      when :hover
        "mouseenter->popover#show mouseleave->popover#hide"
      when :click
        "click->popover#toggle"
      else
        raise ArgumentError, "Unknown trigger_on value: #{trigger_on}. Valid values are :hover and :click"
      end

      options[:data][:action] = action

      # Merge additional data attributes
      options[:data].merge!(data)

      # Create content options
      content_options = { class: content_classes }
      content_options[:class] += " #{width}" if width.present?

      # Set position attributes based on side and align
      content_position = components_popover_position(side, align, side_offset)

      render "feedbackbin_elements/components/popover", {
        trigger: trigger,
        content: content,
        align: align,
        side: side,
        side_offset: side_offset,
        content_options: content_options,
        content_position: content_position,
        options: options
      }
    end

    private

      def components_popover_base_class
        [
          "inline-block relative cursor-pointer"
        ].join(" ")
      end

      def components_popover_content_class
        [
          "hidden absolute z-50 origin-[var(--radix-popover-content-transform-origin)]",
          "rounded-md border bg-popover text-popover-foreground p-4 shadow-md outline-hidden",
          # Animations
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2",
          "data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2",
          # Transitions
          "transition-opacity ease-in-out duration-300"
        ].join(" ")
      end

      def components_popover_position(side, align, offset)
        position_styles = case side
        when :top
          "bottom-full left-1/2 transform -translate-x-1/2 mb-#{offset}"
        when :bottom
          "top-full left-1/2 transform -translate-x-1/2 mt-#{offset}"
        when :left
          "right-full top-1/2 transform -translate-y-1/2 mr-#{offset}"
        when :right
          "left-full top-1/2 transform -translate-y-1/2 ml-#{offset}"
        else
          raise ArgumentError, "Unknown side value: #{side}. Valid values are :top, :right, :bottom, and :left"
        end

        # Adjust alignment
        alignment_styles = case align
        when :start
          if [ :top, :bottom ].include?(side)
            "left-0 transform-none"
          else
            "top-0 transform-none"
          end
        when :center
          "" # Default positioning already centers
        when :end
          if [ :top, :bottom ].include?(side)
            "right-0 left-auto transform-none"
          else
            "bottom-0 top-auto transform-none"
          end
        else
          raise ArgumentError, "Unknown align value: #{align}. Valid values are :start, :center, and :end"
        end

        position_styles + " " + alignment_styles
      end
  end
end
