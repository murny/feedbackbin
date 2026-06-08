# frozen_string_literal: true

require "test_helper"

class Changelog::SearchableTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:feedbackbin)
    Current.account = @account
  end

  test "published changelog creates a Search::Record" do
    changelog = changelogs(:one)

    assert_predicate changelog, :published?

    changelog.reindex

    record = Search::Record.find_by(searchable: changelog)

    assert_not_nil record
    assert_equal "Changelog", record.searchable_type
  end

  test "unpublished changelog does NOT create a Search::Record" do
    changelog = changelogs(:draft)

    assert_not_predicate changelog, :published?

    Search::Record.where(searchable: changelog).destroy_all
    changelog.reindex

    assert_nil Search::Record.find_by(searchable: changelog)
  end

  test "publishing an unpublished changelog refreshes the index" do
    changelog = changelogs(:draft)
    Search::Record.where(searchable: changelog).destroy_all
    changelog.reindex

    assert_nil Search::Record.find_by(searchable: changelog)

    changelog.update!(published_at: Time.current)

    record = Search::Record.find_by(searchable: changelog)

    assert_not_nil record
  end

  test "Search::Record for Changelog has nullable idea_id and board_id" do
    changelog = changelogs(:one)
    changelog.reindex

    record = Search::Record.find_by(searchable: changelog)

    assert_not_nil record
    assert_nil record.idea_id
    assert_nil record.board_id
  end
end
