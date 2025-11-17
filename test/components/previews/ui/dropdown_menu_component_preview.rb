# frozen_string_literal: true

module Ui
  # @label Dropdown Menu
  class DropdownMenuComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render_with_template
    end

    # @label With Icons
    def with_icons
      render_with_template
    end

    # @label With Shortcuts
    def with_shortcuts
      render_with_template
    end

    # @label With Separators
    def with_separators
      render_with_template
    end

    # @label With Labels
    def with_labels
      render_with_template
    end

    # @label With Checkboxes
    def with_checkboxes
      render_with_template
    end

    # @label With Radio Items
    def with_radio_items
      render_with_template
    end

    # @label Inset Items
    def inset_items
      render_with_template
    end

    # @label Disabled Items
    def disabled_items
      render_with_template
    end

    # @label Alignment Variants
    def alignment_variants
      render_with_template
    end
  end
end
