# frozen_string_literal: true

require "test_helper"

class Search::RecordTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:feedbackbin)
    @idea = ideas(:one)
    Current.user = users(:shane)
  end

  test "upsert_for creates a search record for an idea" do
    Search::Record.where(searchable: @idea).destroy_all

    record = Search::Record.upsert_for(@idea)

    assert_predicate record, :persisted?
    assert_equal @idea.title, record.title
    assert_equal @account.id, record.account_id
    assert_equal @idea.board_id, record.board_id
    assert_equal @idea.id, record.idea_id
  end

  test "upsert_for updates existing search record" do
    Search::Record.where(searchable: @idea).destroy_all
    record = Search::Record.upsert_for(@idea)

    record.update!(title: "Old title", content: "Old content")
    updated_record = Search::Record.upsert_for(@idea)

    assert_equal @idea.title, updated_record.title
    assert_equal 1, Search::Record.where(searchable: @idea).count
  end

  test "remove_for destroys the search record" do
    Search::Record.where(searchable: @idea).destroy_all
    Search::Record.upsert_for(@idea)

    assert_difference "Search::Record.count", -1 do
      Search::Record.remove_for(@idea)
    end
  end

  test "search returns matching records via FTS5" do
    Search::Record.destroy_all
    Search::Record.upsert_for(@idea)

    results = Search::Record.search("dark mode", account: @account)

    assert_not_empty results
    assert_equal @idea.id, results.first.idea_id
  end

  test "search returns empty for blank query" do
    results = Search::Record.search("", account: @account)

    assert_empty results
  end

  test "search scopes to account" do
    Search::Record.destroy_all
    Search::Record.upsert_for(@idea)

    other_account = accounts(:acme)
    results = Search::Record.search("dark mode", account: other_account)

    assert_empty results
  end

  test "search filters by board when provided" do
    Search::Record.destroy_all
    Search::Record.upsert_for(@idea)

    board_one = boards(:one)
    board_two = boards(:two)

    results = Search::Record.search("dark", account: @account, board: board_one)

    assert_not_empty results

    results = Search::Record.search("dark", account: @account, board: board_two)

    assert_empty results
  end

  test "search orders ideas before comments" do
    Search::Record.destroy_all
    Search::Record.upsert_for(@idea)

    comment = comments(:one)
    Search::Record.upsert_for(comment)

    results = Search::Record.search("dark", account: @account).to_a

    assert_operator results.size, :>=, 2, "Expected at least 2 results, got #{results.size}"

    idea_idx = results.index { |r| r.searchable_type == "Idea" }
    comment_idx = results.index { |r| r.searchable_type == "Comment" }

    assert_not_nil idea_idx, "Expected an Idea in results"
    assert_not_nil comment_idx, "Expected a Comment in results"
    assert_operator idea_idx, :<, comment_idx
  end
end
