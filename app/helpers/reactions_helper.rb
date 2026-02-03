# frozen_string_literal: true

module ReactionsHelper
  def reaction_path_prefix_for(reactable)
    case reactable
    when Comment
      [ reactable.idea, reactable ]
    else
      raise ArgumentError, "Unknown reactable type: #{reactable.class}"
    end
  end

  def reactions_grouped(reactable)
    reactions = reactable.reactions.includes(:reacter)
    current_user_id = Current.user&.id

    reactions.group_by(&:content).map do |emoji, group|
      user_reaction = group.find { |r| r.reacter_id == current_user_id }

      {
        emoji: emoji,
        count: group.size,
        user_reacted: user_reaction.present?,
        user_reaction_id: user_reaction&.id,
        reacters: group.map(&:reacter)
      }
    end.sort_by { |r| -r[:count] }
  end
end
