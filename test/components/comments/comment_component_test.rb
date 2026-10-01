# frozen_string_literal: true

require "test_helper"

module Comments
  class CommentComponentTest < ViewComponent::TestCase
    test "renders the comment inside a navigable turbo frame" do
      comment = comments(:one)

      render_inline(CommentComponent.new(comment: comment))

      assert_selector "turbo-frame#comment_#{comment.id}[data-navigable-list-target='item'] .panel.panel--compact"
    end

    test "does not render internal comments for non-admins" do
      with_current_user(:jane) do
        render_inline(CommentComponent.new(comment: comments(:internal_one)))
      end

      assert_no_selector "turbo-frame"
    end

    test "renders system comments as a compact notice" do
      comment = comments(:one)
      comment.creator = users(:system)

      render_inline(CommentComponent.new(comment: comment))

      assert_selector "turbo-frame#comment_#{comment.id} .system-comment"
      assert_no_selector ".panel"
    end
  end
end
