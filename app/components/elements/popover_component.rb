# frozen_string_literal: true

module Elements
  class PopoverComponent < BaseComponent
    SIDES = %i[top right bottom left].freeze
    ALIGNS = %i[start center end].freeze
    TRIGGER_MODES = %i[click hover].freeze

    renders_one :trigger
    renders_one :popover_content

    def initialize(
      side: :bottom,
      align: :center,
      side_offset: 4,
      align_offset: 0,
      trigger_mode: :click,
      dismiss_after: nil,
      id: nil,
      **attrs
    )
      @side = validate_option(side, SIDES, "side")
      @align = validate_option(align, ALIGNS, "align")
      @side_offset = side_offset
      @align_offset = align_offset
      @trigger_mode = validate_option(trigger_mode, TRIGGER_MODES, "trigger_mode")
      @dismiss_after = dismiss_after
      @id = id || "popover-#{SecureRandom.hex(4)}"
      @attrs = attrs
    end

    private

      def trigger_id
        "#{@id}-trigger"
      end

      def content_id
        "#{@id}-content"
      end

      def controller_data
        data = {
          controller: "popover",
          popover_trigger_value: @trigger_mode
        }

        data[:popover_dismiss_after_value] = @dismiss_after if @dismiss_after

        data
      end

      def trigger_actions
        case @trigger_mode
        when :click
          "click->popover#toggle"
        when :hover
          "mouseenter->popover#handleMouseEnter mouseleave->popover#handleMouseLeave"
        end
      end

      def trigger_attrs
        {
          id: trigger_id,
          data: {
            slot: "popover-trigger",
            action: trigger_actions,
            popover_target: "trigger"
          },
          aria: {
            haspopup: "dialog",
            expanded: "false",
            controls: content_id
          }
        }
      end

      def wrapper_attrs
        {
          class: tw_merge("relative inline-block", @attrs[:class]),
          data: controller_data.merge(@attrs[:data] || {})
        }.merge(@attrs.except(:class, :data))
      end

      def content_attrs
        {
          id: content_id,
          role: "dialog",
          tabindex: "-1",
          data: {
            slot: "popover-content",
            popover_target: "content",
            state: "closed",
            transition_enter: "transition ease-out duration-200",
            transition_enter_from: "opacity-0 scale-95",
            transition_enter_to: "opacity-100 scale-100",
            transition_leave: "transition ease-in duration-150",
            transition_leave_from: "opacity-100 scale-100",
            transition_leave_to: "opacity-0 scale-95"
          },
          aria: {
            hidden: "true",
            labelledby: trigger_id
          },
          class: content_classes,
          style: position_styles
        }
      end

      def content_classes
        tw_merge(
          base_content_classes,
          position_classes,
          "hidden" # Start hidden
        )
      end

      def base_content_classes
        "absolute z-50 w-72 rounded-md border bg-popover p-4 text-popover-foreground shadow-md outline-none"
      end

      def position_classes
        # Calculate position based on side and align
        classes = []

        # Side positioning (without offset, handled in styles)
        case @side
        when :top
          classes << "bottom-full"
        when :right
          classes << "left-full"
        when :bottom
          classes << "top-full"
        when :left
          classes << "right-full"
        end

        # Alignment
        case @align
        when :start
          if %i[top bottom].include?(@side)
            classes << "left-0"
          else
            classes << "top-0"
          end
        when :center
          if %i[top bottom].include?(@side)
            classes << "left-1/2 -translate-x-1/2"
          else
            classes << "top-1/2 -translate-y-1/2"
          end
        when :end
          if %i[top bottom].include?(@side)
            classes << "right-0"
          else
            classes << "bottom-0"
          end
        end

        classes.join(" ")
      end

      def position_styles
        styles = []

        # Side offset
        case @side
        when :top
          styles << "margin-bottom: #{@side_offset}px"
        when :right
          styles << "margin-left: #{@side_offset}px"
        when :bottom
          styles << "margin-top: #{@side_offset}px"
        when :left
          styles << "margin-right: #{@side_offset}px"
        end

        # Align offset
        if @align_offset != 0
          if %i[top bottom].include?(@side)
            styles << "margin-left: #{@align_offset}px"
          else
            styles << "margin-top: #{@align_offset}px"
          end
        end

        styles.join("; ")
      end
  end
end
