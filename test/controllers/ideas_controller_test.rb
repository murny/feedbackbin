# frozen_string_literal: true

require "test_helper"

class IdeasControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))

    @idea = ideas(:one)
  end

  test "should get index" do
    get ideas_url

    assert_response :success
  end

  test "should get new" do
    get new_idea_url

    assert_response :success
  end

  test "should create idea" do
    assert_difference("Idea.count") do
      post ideas_url, params: { idea: { body: @idea.body, title: @idea.title, board_id: @idea.board_id } }
    end

    assert_redirected_to idea_url(Idea.last)
  end

  test "should show idea" do
    get idea_url(@idea)

    assert_response :success
  end

  test "should get edit" do
    get edit_idea_url(@idea)

    assert_response :success
  end

  test "should update idea" do
    patch idea_url(@idea), params: { idea: { body: @idea.body, title: @idea.title } }

    assert_redirected_to idea_url(@idea)
  end

  test "should destroy idea" do
    assert_difference("Idea.count", -1) do
      delete idea_url(@idea)
    end

    assert_redirected_to ideas_url
  end
end
