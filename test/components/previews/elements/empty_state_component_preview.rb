# frozen_string_literal: true

module Elements
  # @label Empty State
  class EmptyStateComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Elements::EmptyStateComponent.new(
        icon: "inbox",
        title: "No ideas yet",
        description: "Be the first to share an idea!"
      )
    end

    # @label Variants
    def variants
      render_with_template
    end

    # @label With CTA
    def with_cta
      render_with_template
    end
  end
end
