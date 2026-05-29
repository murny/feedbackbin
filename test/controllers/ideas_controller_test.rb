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

  test "index renders empty state when no ideas exist for the account" do
    Idea.where(account: accounts(:feedbackbin)).destroy_all

    get ideas_url

    assert_response :success
    assert_includes response.body, "empty-state__title"
    assert_includes response.body, I18n.t("ideas.index.empty_idea_title")
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

  test "authenticated user visiting new account gets auto-provisioned and can create idea" do
    # Create a new account where the user doesn't have a membership yet
    new_account = Account.create!(name: "Non-Member Test Account")
    creator = new_account.users.create!(name: "Setup", role: :owner)
    new_account.boards.create!(name: "Test Board", color: "#3B82F6", creator: creator)

    shane = users(:shane)

    # Sign in as shane (in the original account context first)
    sign_in_as shane

    # Visit the new account - user should be auto-provisioned
    tenanted(new_account) do
      get new_idea_url

      # User is auto-provisioned and can access the page
      assert_response :success
      assert new_account.users.exists?(identity: shane.identity)

      # User can actually create an idea
      board = new_account.boards.first
      assert_difference("Idea.count") do
        post ideas_url, params: { idea: { title: "Test", description: "Test", board_id: board.id } }
      end
      assert_redirected_to idea_url(Idea.last)
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

      assert_redirected_to sign_in_url
    end
  end

  test "index filters by status_id and marks active filter link with aria-current=page" do
    get ideas_url(status_id: statuses(:planned).id)

    assert_response :success
    assert_select "a[aria-current=page]", text: /Planned/
  end
end
