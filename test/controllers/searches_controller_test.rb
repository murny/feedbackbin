# frozen_string_literal: true

require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
    @idea = ideas(:one)
    Search::Record.upsert_for(@idea)
  end

  test "should get show without query" do
    get search_url

    assert_response :success
  end

  test "should get show with query" do
    get search_url, params: { q: "dark mode" }

    assert_response :success
  end

  test "should return turbo_stream response" do
    get search_url, params: { q: "dark" }, as: :turbo_stream

    assert_response :success
  end

  test "unauthenticated user can search" do
    reset!

    tenanted(accounts(:feedbackbin)) do
      get search_url, params: { q: "dark" }

      assert_response :success
    end
  end

  test "returns empty results for no match" do
    get search_url, params: { q: "zzzznonexistent" }

    assert_response :success
  end

  test "loads recent visits for signed-in user" do
    Visit.where(user: users(:shane)).destroy_all
    Visit.create!(account: accounts(:feedbackbin), user: users(:shane), idea: ideas(:one), visited_at: 1.minute.ago)

    get search_url

    assert_response :success
    assert_match(/Recently viewed/, response.body)
    assert_match(/#{Regexp.escape(ideas(:one).title)}/, response.body)
  end

  test "recent_visits empty for user with no Visit rows" do
    Visit.where(user: users(:shane)).destroy_all

    get search_url

    assert_response :success
    assert_no_match(/data-controller=\"navigable-list\".*Recently viewed/m, response.body)
  end

  test "response includes per-type badges when ideas + comments + changelogs match" do
    Search::Record.destroy_all
    Search::Record.upsert_for(ideas(:one))             # title contains "dark"
    Search::Record.upsert_for(comments(:one))          # idea title contains "dark"
    changelogs(:one).reindex                            # title "We launched this cool feature!" + body "Added dark mode..."

    get search_url, params: { q: "dark" }, as: :turbo_stream

    assert_response :success
    assert_match(/Idea/, response.body)
    assert_match(/Comment/, response.body)
    assert_match(/Changelog/, response.body)
  end
end
