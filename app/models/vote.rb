# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :voter, class_name: "User", default: -> { Current.user }
  belongs_to :voteable, polymorphic: true, touch: true

  validates :voter_id, uniqueness: { scope: %i[voteable_type voteable_id] }

  after_create_commit :watch_idea_by_voter, if: :idea_vote_by_real_user?

  private
    def idea_vote_by_real_user?
      voteable_type == "Idea" && !voter.system? && !voter.bot?
    end

    def watch_idea_by_voter
      voteable.watch_by(voter)
    end
end
