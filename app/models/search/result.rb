# frozen_string_literal: true

class Search::Result
  attr_reader :record, :highlighted_title, :snippet

  delegate :idea, :board, :searchable, :searchable_type, to: :record

  def initialize(record:, highlighted_title: nil, snippet: nil)
    @record = record
    @highlighted_title = highlighted_title
    @snippet = snippet
  end

  def display_title
    escape_fts_highlight(highlighted_title) || record.title
  end

  def display_snippet
    escape_fts_highlight(snippet) || record.content&.truncate(150)
  end

  def idea?
    searchable_type == "Idea"
  end

  def comment?
    searchable_type == "Comment"
  end

  def changelog?
    searchable_type == "Changelog"
  end

  def type_key
    case searchable_type
    when "Idea" then "idea"
    when "Comment" then "comment"
    when "Changelog" then "changelog"
    end
  end

  def display_url
    case searchable_type
    when "Idea"
      Rails.application.routes.url_helpers.idea_path(idea, script_name: Current.account&.slug)
    when "Comment"
      Rails.application.routes.url_helpers.idea_path(idea, anchor: "comment_#{searchable.id}", script_name: Current.account&.slug)
    when "Changelog"
      Rails.application.routes.url_helpers.changelog_path(searchable, script_name: Current.account&.slug)
    end
  end

  private

    def escape_fts_highlight(html)
      return nil unless html.present?

      CGI.escapeHTML(html)
        .gsub("&lt;mark&gt;", "<mark>")
        .gsub("&lt;/mark&gt;", "</mark>")
        .html_safe
    end
end
