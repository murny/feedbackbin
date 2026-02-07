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
    highlighted_title.presence || record.title
  end

  def display_snippet
    snippet.presence || record.content&.truncate(150)
  end

  def idea?
    searchable_type == "Idea"
  end

  def comment?
    searchable_type == "Comment"
  end
end
