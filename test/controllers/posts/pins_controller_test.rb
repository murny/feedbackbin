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

    test "should pin post via turbo stream" do
      sign_in_as(@admin_user)

      assert_not @post.pinned?

      post post_pin_path(@post), as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
      assert_predicate @post.reload, :pinned?

      # Verify turbo stream updates both the button and badge
      assert_match "turbo-stream", @response.body
      assert_match "post-pin-button", @response.body
      assert_match "post-pinned-badge", @response.body
    end

    test "should unpin post via turbo stream" do
      sign_in_as(@admin_user)
      @post.update!(pinned: true)

      assert_predicate @post, :pinned?

      delete post_pin_path(@post), as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
      assert_not @post.reload.pinned?

      # Verify turbo stream updates both the button and badge
      assert_match "turbo-stream", @response.body
      assert_match "post-pin-button", @response.body
      assert_match "post-pinned-badge", @response.body
    end
  end
end
