# frozen_string_literal: true

class Changelog < ApplicationRecord
  TYPES = %w[new fix improvement update]

  include Changelog::Searchable

  belongs_to :account, default: -> { Current.account }
  has_rich_text :description

  has_many :changelog_ideas, dependent: :destroy
  has_many :ideas, through: :changelog_ideas

  validates :kind, presence: true, inclusion: { in: TYPES }
  validates :title, presence: true
  validates :description, presence: true

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  after_update :emit_pending_mention_events, if: -> { saved_change_to_published_at? && published? }

  def published?
    published_at?
  end

  def self.unread?(user)
    most_recent_changelog = published.maximum(:published_at)
    most_recent_changelog && (user.nil? || user.changelogs_read_at&.before?(most_recent_changelog))
  end

  private

    def emit_pending_mention_events
      creator = Current.user || account.system_user

      changelog_ideas.includes(:idea).each do |changelog_idea|
        next if already_emitted_for?(changelog_idea.idea)

        changelog_idea.idea.track_event(
          :mentioned_in_changelog,
          creator: creator,
          changelog_id: id,
          changelog_title: title
        )
      end
    end

    def already_emitted_for?(idea)
      idea.events
        .where(action: "idea_mentioned_in_changelog")
        .any? { |event| event.particulars["changelog_id"] == id }
    end
end
