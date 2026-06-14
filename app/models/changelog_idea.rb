# frozen_string_literal: true

class ChangelogIdea < ApplicationRecord
  belongs_to :account, default: -> { Current.account }
  belongs_to :changelog
  belongs_to :idea

  attr_readonly :changelog_id, :idea_id

  validates :idea_id, uniqueness: { scope: :changelog_id }

  after_create_commit :track_mention_if_published

  private

    def track_mention_if_published
      return unless changelog.published?

      idea.track_event(
        :mentioned_in_changelog,
        changelog_id: changelog.id,
        changelog_title: changelog.title
      )
    end
end
