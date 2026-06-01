# frozen_string_literal: true

require "test_helper"

class Comment::SearchableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @idea = ideas(:one)
  end

  test "saving a public comment creates a Search::Record" do
    comment = @idea.comments.create!(body: "A public searchable comment", creator: users(:shane))

    record = Search::Record.find_by(searchable: comment)

    assert_not_nil record
    assert_equal "Comment", record.searchable_type
  end

  test "saving an internal comment does NOT create a Search::Record" do
    comment = @idea.comments.create!(body: "An internal triage note", creator: users(:shane), internal: true)

    assert_nil Search::Record.find_by(searchable: comment)
  end

  test "Comment#searchable? returns false when internal is true" do
    comment = Comment.new(internal: true)

    assert_not_predicate comment, :searchable?
  end

  test "Comment#searchable? returns true when internal is false" do
    comment = Comment.new(internal: false)

    assert_predicate comment, :searchable?
  end
end
