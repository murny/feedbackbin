# frozen_string_literal: true

require "test_helper"

class Search::ResultTest < ActiveSupport::TestCase
  setup do
    @record = search_records(:idea_one)
  end

  test "idea? returns true for idea searchable type" do
    result = Search::Result.new(record: @record)

    assert_predicate result, :idea?
    assert_not result.comment?
  end

  test "comment? returns true for comment searchable type" do
    record = search_records(:comment_one)
    result = Search::Result.new(record: record)

    assert_predicate result, :comment?
    assert_not result.idea?
  end

  test "display_title returns highlighted title when present" do
    result = Search::Result.new(record: @record, highlighted_title: "<mark>dark</mark> mode")

    assert_equal "<mark>dark</mark> mode", result.display_title
  end

  test "display_title falls back to record title" do
    result = Search::Result.new(record: @record)

    assert_equal @record.title, result.display_title
  end

  test "display_snippet returns snippet when present" do
    result = Search::Result.new(record: @record, snippet: "a <mark>dark</mark> snippet")

    assert_equal "a <mark>dark</mark> snippet", result.display_snippet
  end

  test "display_snippet falls back to truncated content" do
    result = Search::Result.new(record: @record)

    assert_equal @record.content&.truncate(150), result.display_snippet
  end
end
