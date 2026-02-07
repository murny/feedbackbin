# frozen_string_literal: true

require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  setup do
    with_current_user(users(:shane)) do
      @user = users(:shane)
    end
    Current.user = @user
  end

  test "creating an idea creates a search record" do
    board = boards(:one)

    assert_difference "Search::Record.count" do
      Idea.create!(title: "Searchable idea", board: board)
    end
  end

  test "updating an idea updates the search record" do
    idea = ideas(:one)
    Search::Record.upsert_for(idea)

    idea.update!(title: "Updated searchable title")

    record = Search::Record.find_by(searchable: idea)

    assert_equal "Updated searchable title", record.title
  end

  test "destroying an idea destroys the search record" do
    idea = ideas(:one)
    Search::Record.upsert_for(idea)
    idea_search_record = Search::Record.find_by(searchable: idea)

    idea.destroy!

    assert_nil Search::Record.find_by(id: idea_search_record.id)
  end

  test "creating a comment creates a search record" do
    idea = ideas(:one)

    assert_difference "Search::Record.count" do
      Comment.create!(idea: idea, body: "Searchable comment body")
    end
  end

  test "destroying a comment destroys the search record" do
    comment = comments(:one)
    Search::Record.upsert_for(comment)

    assert_difference "Search::Record.count", -1 do
      comment.destroy!
    end
  end
end
