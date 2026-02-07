# frozen_string_literal: true

require "test_helper"

class Searches::QueriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
  end

  test "should create a search query" do
    assert_difference "Search::Query.count" do
      post searches_queries_url, params: { terms: "test search" }
    end

    assert_response :ok
  end

  test "requires authentication" do
    reset!

    tenanted(accounts(:feedbackbin)) do
      post searches_queries_url, params: { terms: "test" }

      assert_redirected_to sign_in_url
    end
  end
end
