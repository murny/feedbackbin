# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = posts(:one)
  end

  test "valid post" do
    assert_predicate @post, :valid?
  end

  test "invalid without a title" do
    @post.title = nil

    assert_not @post.valid?
    assert_equal "can't be blank", @post.errors[:title].first
  end

  test "invalid without a author" do
    @post.author = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:author].first
  end

  test "invalid without a category" do
    @post.category = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:category].first
  end

  test "invalid without an organization" do
    @post.organization = nil

    assert_not @post.valid?
    assert_equal "must exist", @post.errors[:organization].first
  end

  test "should initialize views_count to 0" do
    new_post = Post.create!(
      title: "Test Post",
      body: "Test content",
      author: users(:jane),
      category: categories(:general),
      organization: organizations(:acme)
    )
    
    assert_equal 0, new_post.views_count
  end

  test "should increment view count" do
    initial_count = @post.views_count
    @post.increment_view_count!
    
    assert_equal initial_count + 1, @post.views_count
  end

  test "should pin and unpin posts" do
    assert_not @post.pinned?
    
    @post.pin!
    assert @post.pinned?
    
    @post.unpin!
    assert_not @post.pinned?
  end

  test "should handle tag names assignment" do
    @post.tag_names = ["react", "javascript", "web-dev"]
    @post.save!
    
    assert_equal 3, @post.tags.count
    assert_includes @post.tag_names, "react"
    assert_includes @post.tag_names, "javascript"
    assert_includes @post.tag_names, "web-dev"
  end

  test "should return status indicator color" do
    # Test pinned posts
    @post.pin!
    assert_equal "#3b82f6", @post.status_indicator_color
    
    # Test custom status color
    @post.status_color = "#ff0000"
    assert_equal "#ff0000", @post.status_indicator_color
  end

  test "should filter by tag" do
    tag = Tag.create!(name: "test-tag", organization: @post.organization)
    @post.tags << tag
    
    results = Post.with_tag("test-tag")
    assert_includes results, @post
  end

  test "should scope pinned posts" do
    @post.pin!
    
    pinned_posts = Post.pinned
    assert_includes pinned_posts, @post
    
    unpinned_posts = Post.unpinned
    assert_not_includes unpinned_posts, @post
  end
end
