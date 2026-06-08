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

  test "search orders results by bm25 relevance" do
    Search::Record.destroy_all

    body_only_match = Idea.create!(
      title: "Voting feature suggestion",
      description: "Please add dark-mode-aware voting controls so toggles match the canvas tone.",
      creator: users(:shane),
      board: boards(:one)
    )

    Search::Record.upsert_for(ideas(:one))     # title match: "Wish this had dark mode!"
    Search::Record.upsert_for(body_only_match) # body-only match

    results = Search::Record.search("dark", account: @account).to_a

    assert_equal 2, results.size
    assert_equal ideas(:one).id, results.first.idea_id,
      "title match should outrank body-only match in bm25 ordering"
    assert_equal body_only_match.id, results.last.idea_id
  end

  test "search returns none for pure-punctuation query" do
    results = Search::Record.search("???", account: @account)

    assert_empty results
  end

  test "search populates result_title with FTS5 highlight marks" do
    Search::Record.destroy_all
    Search::Record.upsert_for(@idea)

    record = Search::Record.search("dark", account: @account).first

    assert_match(/<mark>dark<\/mark>/i, record.result_title)
  end

  test "search populates result_content with FTS5 snippet" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))

    record = Search::Record.search("dark", account: @account).first

    assert_not_nil record.result_content
  end

  test "display_title returns highlighted title when present" do
    record = Search::Record.upsert_for(@idea)
    record.result_title = "<mark>dark</mark> mode"

    assert_equal "<mark>dark</mark> mode", record.display_title
  end

  test "display_title falls back to raw title when no highlight" do
    record = Search::Record.upsert_for(@idea)

    assert_equal @idea.title, record.display_title
  end

  test "display_snippet returns escaped snippet when present" do
    record = Search::Record.upsert_for(@idea)
    record.result_content = "a <mark>dark</mark> snippet"

    assert_equal "a <mark>dark</mark> snippet", record.display_snippet
  end

  test "display_snippet escapes HTML in user content while preserving mark tags" do
    record = Search::Record.upsert_for(@idea)
    record.result_content = "danger <script>alert(1)</script> <mark>dark</mark>"

    snippet = record.display_snippet

    assert_includes snippet, "<mark>dark</mark>"
    assert_includes snippet, "&lt;script&gt;"
    assert_not_includes snippet, "<script>"
  end

  test "type predicates reflect searchable_type" do
    idea_record    = Search::Record.upsert_for(ideas(:one))
    comment_record = Search::Record.upsert_for(comments(:one))

    assert_predicate idea_record, :idea?
    assert_not idea_record.comment?
    assert_predicate comment_record, :comment?
    assert_not comment_record.idea?
  end

  test "type_key returns lowercase string for searchable_type" do
    assert_equal "idea", Search::Record.upsert_for(ideas(:one)).type_key
    assert_equal "comment", Search::Record.upsert_for(comments(:one)).type_key
  end
end
