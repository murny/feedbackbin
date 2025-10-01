# frozen_string_literal: true

module ChangelogsHelper
  CHANGELOG_COLORS = {
    "new" => "bg-blue-100 text-blue-600",
    "update" => " bg-green-100 text-green-600",
    "improvement" => "bg-purple-100 text-purple-600",
    "fix" => "bg-red-100 text-red-600"
  }

  CHANGELOG_BADGE_VARIANTS = {
    "new" => :default,
    "update" => :secondary,
    "improvement" => :outline,
    "fix" => :destructive
  }

  def changelog_color(changelog)
    CHANGELOG_COLORS.fetch(changelog.kind, "bg-green-100 text-green-600")
  end

  def changelog_badge_variant(kind)
    CHANGELOG_BADGE_VARIANTS.fetch(kind, :secondary)
  end

  def unread_changelogs_class(user)
    "inline-block w-2 h-2 mr-1.5 rounded-full bg-red-500 content-['']" if Changelog.unread?(user)
  end
end
