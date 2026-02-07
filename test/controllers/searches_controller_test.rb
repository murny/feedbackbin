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
end
