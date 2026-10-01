# frozen_string_literal: true

module Ideas
  # @label Status Badge
  class StatusBadgeComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ideas::StatusBadgeComponent.new(idea: Idea.first!)
    end
  end
end
