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
          class: [ "popover", @attrs[:class] ].compact.join(" "),
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
            state: "closed"
          },
          aria: {
            hidden: "true",
            labelledby: trigger_id
          },
          class: content_classes,
          style: offset_styles
        }
      end

      def content_classes
        [
          "popover__content",
          "display-none",
          position_class,
          alignment_class
        ].compact.join(" ")
      end

      def position_class
        case @side
        when :top then "popover__content--top"
        when :right then "popover__content--right"
        when :left then "popover__content--left"
        else nil
        end
      end

      def alignment_class
        case @align
        when :start then "popover__content--start"
        when :end then "popover__content--end"
        else nil
        end
      end

      def offset_styles
        styles = []

        if @side_offset != 4
          styles << "--popover-offset: #{@side_offset}px"
        end

        if @align_offset != 0
          case @side
          when :top, :bottom
            styles << "margin-left: #{@align_offset}px"
          when :left, :right
            styles << "margin-top: #{@align_offset}px"
          end
        end

        styles.any? ? styles.join("; ") : nil
      end
  end
end
