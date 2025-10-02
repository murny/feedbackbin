# frozen_string_literal: true

require "test_helper"

module Admin
  class PostsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      @post = posts(:one)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_posts_path

      assert_response :success
      assert_includes @response.body, "Posts"
    end

    test "should get index with search" do
      get admin_posts_path, params: { search: "dark" }

      assert_response :success
      assert_includes @response.body, "dark"
    end

    test "should get index as turbo_stream" do
      get admin_posts_path, as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
    end

    test "should show post" do
      get admin_post_path(@post)

      assert_response :success
      assert_includes @response.body, @post.title
    end

    test "should require authentication" do
      sign_out
      get admin_posts_path

      assert_redirected_to sign_in_path
    end
  end
end
