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

  private

    def escape_fts_highlight(html)
      return nil unless html.present?

      CGI.escapeHTML(html)
        .gsub("&lt;mark&gt;", "<mark>")
        .gsub("&lt;/mark&gt;", "</mark>")
        .html_safe
    end
end
