# frozen_string_literal: true

module Ui
  # @label Popover
  class PopoverComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::PopoverComponent.new do |popover|
        popover.with_trigger do
          render Ui::ButtonComponent.new do
            "Open popover"
          end
        end

        popover.with_content do
          tag.div(class: "space-y-2") do
            tag.h4("Dimensions", class: "font-medium leading-none") +
            tag.p("Set the dimensions for the layer.", class: "text-sm text-muted-foreground")
          end
        end
      end
    end

    # @label Positions (Sides)
    def positions
      render_with_template locals: {
        sides: Ui::PopoverComponent::SIDES
      }
    end

    # @label Alignments
    def alignments
      render_with_template
    end

    # @label Hover Trigger
    def hover_trigger
      render Ui::PopoverComponent.new(trigger_mode: :hover) do |popover|
        popover.with_trigger do
          render Ui::ButtonComponent.new(variant: :outline) do
            "Hover me"
          end
        end

        popover.with_content do
          tag.div(class: "space-y-2") do
            tag.h4("Hover Popover", class: "font-medium leading-none") +
            tag.p("This popover appears on hover.", class: "text-sm text-muted-foreground")
          end
        end
      end
    end

    # @label Auto Dismiss
    def auto_dismiss
      render Ui::PopoverComponent.new(dismiss_after: 3000) do |popover|
        popover.with_trigger do
          render Ui::ButtonComponent.new(variant: :secondary) do
            "Auto-dismiss (3s)"
          end
        end

        popover.with_content do
          tag.div(class: "space-y-2") do
            tag.h4("Auto Dismiss", class: "font-medium leading-none") +
            tag.p("This popover will automatically close after 3 seconds.", class: "text-sm text-muted-foreground")
          end
        end
      end
    end

    # @label With Form
    def with_form
      render_with_template
    end

    # @label Rich Content
    def rich_content
      render_with_template
    end
  end
end
