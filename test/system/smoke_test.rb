# frozen_string_literal: true

require "application_system_test_case"

class SmokeTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:feedbackbin)
    @user = users(:shane)
    @board = boards(:one)
    @idea = ideas(:one)
    @unvoted_idea = ideas(:two)
  end

  test "signing in" do
    sign_in_as(@user)

    assert_text "You have signed in successfully."
  end

  test "creating an idea" do
    sign_in_as(@user)

    visit new_idea_url(script_name: @account.slug)
    select @board.name, from: "Board"
    fill_in "Title", with: "Smoke test idea"
    fill_in_lexxy with: "Smoke test description body."
    click_button "Create Idea"

    assert_text "Idea was successfully created"
    assert_text "Smoke test idea"
  end

  test "voting on an idea" do
    sign_in_as(@user)

    visit idea_url(@unvoted_idea, script_name: @account.slug)

    initial_count = @unvoted_idea.reload.votes_count
    within ".vote" do
      first("button").click
    end

    assert_selector ".vote__count", text: (initial_count + 1).to_s
  end

  test "commenting on an idea" do
    sign_in_as(@user)

    visit idea_url(@idea, script_name: @account.slug)
    fill_in_lexxy with: "Smoke test comment body."
    click_button "Create Comment"

    assert_text "Smoke test comment body."
  end
end
