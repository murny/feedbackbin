# frozen_string_literal: true

module Ideas
  # @label Idea Card
  class CardComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render_with_template(locals: { ideas: Idea.limit(3) })
    end
  end
end
