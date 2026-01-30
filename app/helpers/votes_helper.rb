# frozen_string_literal: true

module VotesHelper
  def voteable_vote_path(voteable)
    case voteable
    when Idea
      idea_vote_path(voteable)
    when Comment
      idea_comment_vote_path(voteable.idea, voteable)
    else
      raise ArgumentError, "Unknown voteable type: #{voteable.class}"
    end
  end
end
