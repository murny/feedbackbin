# frozen_string_literal: true

require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit root_url

    assert_selector "a", text: "New Post"
  end

  # TODO: Fix this test, need UI around Boards
  # test "should create post" do
  #   sign_in(users(:shane).email_address)

  #   visit posts_url
  #   click_link "New Post"

  #   fill_in_rich_text_area "Body", with: @post.body
  #   fill_in "Title", with: @post.title
  #   click_button "Create Post"

  #   assert_text "Post was successfully created"
  # end

  # test "should update Post" do
  #   sign_in(users(:shane).email_address)

  #   visit post_url(@post)
  #   # Click the dropdown menu button (ellipsis icon)
  #   find('[data-dropdown-target="button"]').click
  #   # Now click the Edit link within the dropdown
  #   click_link "Edit"

  #   fill_in_rich_text_area "Body", with: @post.body
  #   fill_in "Title", with: "Updated title goes here"
  #   click_button "Update Post"

  #   assert_text "Post was successfully updated"
  # end

  # test "should destroy Post" do
  #   sign_in(users(:shane).email_address)

  #   visit post_url(@post)
  #   # Click the dropdown menu button (ellipsis icon)
  #   find('[data-dropdown-target="button"]').click
  #   # Now click the Edit link within the dropdown
  #   click_link "Edit"

  #   accept_confirm do
  #     click_button "Delete", match: :first
  #   end

  #   assert_text "Post was successfully destroyed"
  # end
end
