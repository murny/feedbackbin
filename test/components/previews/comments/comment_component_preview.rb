# frozen_string_literal: true

module Comments
  # @label Comment
  class CommentComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render_with_template(locals: { comments: Comment.where(parent_id: nil, internal: false).limit(3) })
    end
  end
end
