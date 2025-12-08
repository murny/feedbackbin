# frozen_string_literal: true

require "test_helper"

class Post::PinnableTest < ActiveSupport::TestCase
  setup do
    @post = posts(:one)
    Current.organization = organizations(:feedbackbin)
  end

  test "pinned scope returns only pinned posts" do
    @post.update!(pinned: true)
    other_post = posts(:two)
    other_post.update!(pinned: false)

    pinned_posts = Post.pinned

    assert_includes pinned_posts, @post
    assert_not_includes pinned_posts, other_post
  end

  test "unpinned scope returns only unpinned posts" do
    @post.update!(pinned: true)
    other_post = posts(:two)
    other_post.update!(pinned: false)

    unpinned_posts = Post.unpinned

    assert_not_includes unpinned_posts, @post
    assert_includes unpinned_posts, other_post
  end

  test "ordered_with_pinned scope orders pinned posts first" do
    # Create posts with different pinned states and times
    unpinned_old = @post
    unpinned_old.update!(pinned: false, created_at: 3.days.ago)

    pinned_old = posts(:two)
    pinned_old.update!(pinned: true, created_at: 2.days.ago)

    posts = Post.ordered_with_pinned.limit(2)

    # Pinned posts should come first regardless of creation date
    assert_equal pinned_old, posts.first
  end

  test "pinned? returns true when post is pinned" do
    @post.update!(pinned: true)

    assert_predicate @post, :pinned?
  end

  test "pinned? returns false when post is not pinned" do
    @post.update!(pinned: false)

    assert_not @post.pinned?
  end

  test "pin! sets post as pinned" do
    @post.update!(pinned: false)

    @post.pin!

    assert_predicate @post, :pinned?
    assert @post.reload.pinned
  end

  test "unpin! sets post as unpinned" do
    @post.update!(pinned: true)

    @post.unpin!

    assert_not @post.pinned?
    assert_not @post.reload.pinned
  end
end
