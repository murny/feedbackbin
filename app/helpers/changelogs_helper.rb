module ChangelogsHelper
  CHANGELOG_COLORS = {
    "new" => "bg-primary-100 text-primary-600",
    "update" => " bg-green-100 text-green-600",
    "improvement" => "bg-purple-100 text-purple-600",
    "fix" => "bg-red-100 text-red-600"
  }

  def changelog_color(changelog)
    CHANGELOG_COLORS.fetch(changelog.kind, "bg-green-100 text-green-600")
  end

  def unread_changelogs_class(user)
    "inline-block w-2 h-2 mr-1.5 rounded-full bg-red-500 content-['']" if Changelog.unread?(user)
  end
end
