# frozen_string_literal: true

module Ui
  # @label Popover
  class PopoverComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render_with_template
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
      render_with_template
    end

    # @label Auto Dismiss
    def auto_dismiss
      render_with_template
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
