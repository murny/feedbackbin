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
      post ideas_url, params: { idea: { description: @idea.description, title: @idea.title, board_id: @idea.board_id } }
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
    patch idea_url(@idea), params: { idea: { description: @idea.description, title: @idea.title } }

    assert_redirected_to idea_url(@idea)
  end

  test "should destroy idea" do
    assert_difference("Idea.count", -1) do
      delete idea_url(@idea)
    end

    assert_redirected_to ideas_url
  end

  test "authenticated non-member should be redirected to sign up when creating idea" do
    # Create a new account where the user doesn't have a membership
    new_account = Account.create!(name: "Non-Member Test Account")
    new_account.boards.create!(name: "Test Board", color: "#3B82F6")

    shane = users(:shane)

    # Sign in as shane (in the original account context first)
    sign_in_as shane

    # Now try to create an idea in the new account (where they're not a member)
    tenanted(new_account) do
      get new_idea_url

      # Should be redirected to sign up with a message about joining
      assert_redirected_to users_sign_up_url
      assert_match /Join this account/, flash[:alert]
    end
  end

  test "unauthenticated user can view ideas" do
    # Start fresh without signing in
    reset!

    tenanted(accounts(:feedbackbin)) do
      get ideas_url

      assert_response :success
    end
  end

  test "unauthenticated user is redirected to sign in when creating idea" do
    # Start fresh without signing in
    reset!

    tenanted(accounts(:feedbackbin)) do
      get new_idea_url

      assert_redirected_to users_sign_in_url
    end
  end
end
