# frozen_string_literal: true

require "test_helper"

module Posts
  class PinsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @post = posts(:one)
      @admin_user = users(:shane)
    end

    test "should pin post when user is admin" do
      sign_in_as(@admin_user)

      assert_not @post.pinned?

      post post_pin_path(@post)

      assert_response :redirect
      assert_redirected_to @post
      assert_predicate @post.reload, :pinned?
      assert_match "Post has been pinned", flash[:notice]
    end

    test "should unpin post when user is admin" do
      sign_in_as(@admin_user)
      @post.update!(pinned: true)

      assert_predicate @post, :pinned?

      delete post_pin_path(@post)

      assert_response :redirect
      assert_redirected_to @post
      assert_not @post.reload.pinned?
      assert_match "Post has been unpinned", flash[:notice]
    end

    test "should redirect unauthenticated user trying to pin post" do
      post post_pin_path(@post)

      assert_response :redirect
      assert_not @post.reload.pinned?
    end

    test "should redirect unauthenticated user trying to unpin post" do
      @post.update!(pinned: true)

      delete post_pin_path(@post)

      assert_response :redirect
      assert_predicate @post.reload, :pinned?
    end
  end
end
