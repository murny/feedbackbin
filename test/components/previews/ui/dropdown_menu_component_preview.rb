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
  end
end
