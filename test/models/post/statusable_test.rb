# frozen_string_literal: true

require "test_helper"

class Post::StatusableTest < ActiveSupport::TestCase
  setup do
    @post = posts(:one)
    @organization = organizations(:feedbackbin)
    @user = users(:shane)
    Current.organization = @organization
    Current.session = sessions(:shane_chrome)
  end

  test "belongs to post_status" do
    assert_not_nil @post.post_status
    assert_instance_of PostStatus, @post.post_status
  end

  test "uses organization's default post_status for new posts" do
    post = Post.create!(
      title: "New Post",
      body: "Content",
      author: @user,
      category: categories(:one)
    )

    assert_equal @organization.default_post_status, post.post_status
  end

  test "with_status scope filters posts by status" do
    status = post_statuses(:planned)
    @post.update!(post_status: status)

    posts = Post.with_status(status)

    assert_includes posts, @post
  end

  test "by_status scope orders posts by status position" do
    posts = Post.by_status

    # Should be ordered by post_statuses.position
    assert_equal Post, posts.first.class
  end

  test "status returns post_status" do
    assert_equal @post.post_status, @post.status
  end

  test "change_status updates post_status and tracks event" do
    old_status = @post.post_status
    new_status = post_statuses(:planned)

    assert_difference -> { Event.count }, 1 do
      @post.change_status(new_status, user: @user)
    end

    @post.reload
    assert_equal new_status, @post.post_status

    event = Event.last
    assert_equal "post_status_changed", event.action
    assert_equal @user, event.creator
    assert_equal old_status.name, event.particulars["from_status"]
    assert_equal new_status.name, event.particulars["to_status"]
  end

  test "change_status uses Current.user when user not specified" do
    new_status = post_statuses(:planned)

    @post.change_status(new_status)

    event = Event.last
    assert_equal @user, event.creator
  end
end
