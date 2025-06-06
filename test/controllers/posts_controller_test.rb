# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))

    @post = posts(:one)
  end

  test "should get index" do
    get posts_url

    assert_response :success
  end

  test "should get new" do
    sign_in_as(users(:shane))

    get new_post_url

    assert_response :success
  end

  test "should create post" do
    sign_in_as(users(:shane))

    assert_difference("Post.count") do
      post posts_url, params: { post: { body: @post.body, title: @post.title, category_id: @post.category_id } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)

    assert_response :success
  end

  test "should get edit" do
    sign_in_as(users(:shane))

    get edit_post_url(@post)

    assert_response :success
  end

  test "should update post" do
    sign_in_as(users(:shane))

    patch post_url(@post), params: { post: { body: @post.body, title: @post.title } }

    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    sign_in_as(users(:shane))

    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end
end
