# frozen_string_literal: true

class Changelog < ApplicationRecord
  TYPES = %w[new fix improvement update]

  belongs_to :organization, default: -> { Current.organization }

  has_rich_text :description

  validates :kind, presence: true, inclusion: {in: TYPES}
  validates :title, presence: true
  validates :description, presence: true

  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where.not(published_at: nil) }

  # TODO: Investigate if we need this when we build the CRUD form for changelogs
  attribute :published_at, default: -> { Time.current }

  def self.unread?(user)
    most_recent_changelog = published.maximum(:published_at)
    most_recent_changelog && (user.nil? || user.changelogs_read_at&.before?(most_recent_changelog))
  end
end
