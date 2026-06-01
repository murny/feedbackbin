# frozen_string_literal: true

require "test_helper"

class Ideas::SimilarControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
    Search::Record.destroy_all
    @idea = ideas(:one) # "Wish this had dark mode!"
    Search::Record.upsert_for(@idea)
  end

  test "returns matching ideas as a partial" do
    get similar_ideas_url, params: { title: "dark" }

    assert_response :success
    assert_includes response.body, @idea.title
  end

  test "returns empty frame when title below min length" do
    get similar_ideas_url, params: { title: "ab" }

    assert_response :success
    assert_not_includes response.body, @idea.title
  end

  test "respects account scope" do
    Search::Record.upsert_for(ideas(:acme_one))

    get similar_ideas_url, params: { title: "Acme" }

    assert_response :success
    assert_not_includes response.body, ideas(:acme_one).title
  end
end
