# frozen_string_literal: true

require "application_system_test_case"

class IdeasTest < ApplicationSystemTestCase
  setup do
    @account = accounts(:feedbackbin)
  end

  test "visiting the index" do
    # Visit account-scoped root URL
    visit root_url(script_name: @account.slug)

    assert_selector "a", text: "New Idea"
  end

  # TODO: Fix this test, need UI around Boards
  # test "should create idea" do
  #   sign_in(users(:shane).email_address)

  #   visit ideas_url
  #   click_link "New Idea"

  #   fill_in_rich_text_area "Body", with: @idea.description
  #   fill_in "Title", with: @idea.title
  #   click_button "Create Idea"

  #   assert_text "Idea was successfully created"
  # end

  # test "should update Idea" do
  #   sign_in(users(:shane).email_address)

  #   visit idea_url(@idea)
  #   # Click the dropdown menu button (ellipsis icon)
  #   find('[data-dropdown-target="button"]').click
  #   # Now click the Edit link within the dropdown
  #   click_link "Edit"

  #   fill_in_rich_text_area "Body", with: @idea.description
  #   fill_in "Title", with: "Updated title goes here"
  #   click_button "Update Idea"

  #   assert_text "Idea was successfully updated"
  # end

  # test "should destroy Idea" do
  #   sign_in(users(:shane).email_address)

  #   visit idea_url(@idea)
  #   # Click the dropdown menu button (ellipsis icon)
  #   find('[data-dropdown-target="button"]').click
  #   # Now click the Edit link within the dropdown
  #   click_link "Edit"

  #   accept_confirm do
  #     click_button "Delete", match: :first
  #   end

  #   assert_text "Idea was successfully destroyed"
  # end
end
