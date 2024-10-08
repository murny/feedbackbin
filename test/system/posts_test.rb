# frozen_string_literal: true

require "application_system_test_case"

class PostsTest < ApplicationSystemTestCase
  setup do
    @post = posts(:one)
  end

  test "visiting the index" do
    visit posts_url

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

  test "should update Post" do
    sign_in(users(:shane).email_address)

    visit post_url(@post)
    click_link "Edit", match: :first

    fill_in_rich_text_area "Body", with: @post.body
    fill_in "Title", with: @post.title
    click_button "Update Post"

    assert_text "Post was successfully updated"
  end

  test "should destroy Post" do
    sign_in(users(:shane).email_address)

    visit post_url(@post)
    click_link "Edit", match: :first

    accept_confirm do
      click_button "Delete", match: :first
    end

    assert_text "Post was successfully destroyed"
  end
end
