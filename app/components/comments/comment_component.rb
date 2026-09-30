# frozen_string_literal: true

module Comments
  class CommentComponent < Elements::BaseComponent
    VISIBLE_REPLIES_LIMIT = 3
    COLLAPSE_REPLIES_THRESHOLD = 5

    include Turbo::FramesHelper

    def initialize(comment:)
      @comment = comment
    end

    def render?
      !@comment.internal? || Current.user&.admin?
    end

    private

      def can_reply?
        helpers.authenticated? && (!@comment.idea.comments_locked? || Current.user.admin?)
      end

      def replies
        @replies ||= @comment.replies.ordered.to_a
      end

      def collapse_replies?
        replies.size >= COLLAPSE_REPLIES_THRESHOLD
      end

      def visible_replies
        collapse_replies? ? replies.first(VISIBLE_REPLIES_LIMIT) : replies
      end

      def collapsed_replies
        replies.drop(VISIBLE_REPLIES_LIMIT)
      end
  end
end
