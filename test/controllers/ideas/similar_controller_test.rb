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
    # Title is rendered with <mark> wrapping the matched term, so assert on the
    # surrounding text and the highlight markup separately.
    assert_match %r{Wish this had <mark>dark</mark> mode!}, response.body
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

  test "excludes idea_id from results when passed" do
    duplicate = Idea.create!(
      title: "Wish this had dark theme support too",
      creator: users(:shane),
      board: boards(:one)
    )
    Search::Record.upsert_for(duplicate)

    get similar_ideas_url, params: { title: "dark", idea_id: @idea.id }

    assert_response :success
    assert_not_includes response.body, "Wish this had <mark>dark</mark> mode!"
    assert_match %r{Wish this had <mark>dark</mark> theme support too}, response.body
  end

  test "new form renders similar_ideas turbo frame" do
    get new_idea_url

    assert_response :success
    assert_includes response.body, 'id="similar_ideas"'
    assert_includes response.body, 'data-controller="similar-ideas"'
  end

  test "edit form does not render similar_ideas turbo frame" do
    get edit_idea_url(@idea)

    assert_response :success
    assert_not_includes response.body, 'id="similar_ideas"'
    assert_not_includes response.body, 'data-controller="similar-ideas"'
  end
end
