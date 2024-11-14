# frozen_string_literal: true

class Changelog < ApplicationRecord
  TYPES = %w[new fix improvement update]

  belongs_to :account, default: -> { Current.account }

  has_rich_text :description

  validates :kind, presence: true, inclusion: {in: TYPES}
  validates :title, presence: true
  validates :description, presence: true
  validates :published_at, presence: true

  attribute :published_at, default: -> { Time.current }

  def self.unread?(user)
    most_recent_changelog = maximum(:published_at)
    most_recent_changelog && (user.nil? || user.changelogs_read_at&.before?(most_recent_changelog))
  end
end
