# frozen_string_literal: true

module ChangelogsHelper
  CHANGELOG_BADGE_VARIANTS = {
    "new" => :default,
    "fix" => :destructive,
    "improvement" => :success,
    "update" => :warning
  }

  def changelog_badge_variant(kind)
    CHANGELOG_BADGE_VARIANTS.fetch(kind, :secondary)
  end

  def unread_changelogs_class(user)
    "inline-block w-2 h-2 mr-1.5 rounded-full bg-red-500 content-['']" if Changelog.unread?(user)
  end
end
