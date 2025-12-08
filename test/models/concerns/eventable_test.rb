# frozen_string_literal: true

require "test_helper"

class EventableTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:feedbackbin)
    @user = users(:shane)
    @session = sessions(:shane_chrome)
    Current.organization = @organization
    Current.session = @session
  end

  # Post event tracking tests
  test "creates event when post is created" do
    assert_difference -> { Event.count }, 1 do
      Post.create!(
        title: "New Post",
        body: "Post body",
        author: @user,
        category: categories(:one),
        post_status: post_statuses(:open)
      )
    end

    event = Event.last

    assert_equal "post_created", event.action
    assert_equal @user, event.creator
    assert_equal @organization, event.organization
  end

  test "creates event when post is updated" do
    post = posts(:one)

    assert_difference -> { Event.count }, 1 do
      post.update!(title: "Updated Title")
    end

    event = Event.last

    assert_equal "post_updated", event.action
    assert_equal post.author, event.creator
    assert_equal post, event.eventable
  end

  test "does not create event when post is updated without title or body change" do
    post = posts(:one)

    assert_no_difference -> { Event.count } do
      post.update!(pinned: true)
    end
  end

  test "creates event when post is destroyed" do
    post = posts(:one)

    # Destroying a post also destroys its comments, which creates additional events
    # So we expect multiple events, but we'll verify the post deletion event exists
    post.destroy!

    # Check that a post_deleted event was created
    post_deleted_events = Event.where(action: "post_deleted", eventable_type: "Post")

    assert_predicate post_deleted_events, :exists?, "Expected post_deleted event to be created"

    event = post_deleted_events.last

    assert_equal "post_deleted", event.action
  end

  # Comment event tracking tests
  test "creates event when comment is created" do
    post = posts(:one)

    assert_difference -> { Event.count }, 1 do
      Comment.create!(
        body: "New comment",
        creator: @user,
        post: post
      )
    end

    event = Event.last

    assert_equal "comment_created", event.action
    assert_equal @user, event.creator
  end

  # Note: Comment updates don't create events because body is a rich_text attribute
  # We can't easily track changes to ActionText rich text attributes
  # If we want to track comment updates, we'd need to add a custom callback

  test "creates event when comment is destroyed" do
    comment = comments(:one)

    assert_difference -> { Event.count }, 1 do
      comment.destroy!
    end

    event = Event.last

    assert_equal "comment_deleted", event.action
  end

  # Category event tracking tests
  test "creates event when category is created" do
    assert_difference -> { Event.count }, 1 do
      Category.create!(
        name: "New Category",
        color: "#ff0000"
      )
    end

    event = Event.last

    assert_equal "category_created", event.action
    assert_equal @user, event.creator
  end

  test "creates event when category is updated" do
    category = categories(:one)

    assert_difference -> { Event.count }, 1 do
      category.update!(name: "Updated Category Name")
    end

    event = Event.last

    assert_equal "category_updated", event.action
  end

  test "creates event when category is destroyed" do
    # Create a category without posts so we can delete it
    category = Category.create!(name: "Deletable", color: "#00ff00")

    # Creating the category above already created 1 event
    # Now destroy it and check for the deletion event
    category.destroy!

    deletion_events = Event.where(action: "category_deleted", eventable_type: "Category")

    assert_predicate deletion_events, :exists?, "Expected category_deleted event to be created"

    event = deletion_events.last

    assert_equal "category_deleted", event.action
  end

  # User event tracking tests
  test "creates event when user profile is updated" do
    user = users(:one)

    assert_difference -> { Event.count }, 1 do
      user.update!(name: "New Name")
    end

    event = Event.last

    assert_equal "user_profile_updated", event.action
    assert_equal @user, event.creator
  end

  test "creates event when user is deactivated" do
    user = users(:one)

    assert_difference -> { Event.count }, 1 do
      user.update!(active: false)
    end

    event = Event.last

    assert_equal "user_deactivated", event.action
  end

  test "creates event when user is activated" do
    user = users(:one)
    user.update!(active: false) # Deactivate first

    Event.destroy_all # Clear events to test activation

    assert_difference -> { Event.count }, 1 do
      user.update!(active: true)
    end

    event = Event.last

    assert_equal "user_activated", event.action
  end

  # Test event creator attribution
  test "event uses author as creator for posts" do
    different_user = users(:one)

    post = Post.create!(
      title: "Post by different user",
      body: "Body",
      author: different_user,
      category: categories(:one),
      post_status: post_statuses(:open)
    )

    event = Event.last

    assert_equal different_user, event.creator
    assert_not_equal @user, event.creator
  end

  test "event uses creator as creator for comments" do
    different_user = users(:one)

    comment = Comment.create!(
      body: "Comment by different user",
      creator: different_user,
      post: posts(:one)
    )

    event = Event.last

    assert_equal different_user, event.creator
  end

  test "event uses system user when current user is nil" do
    Current.session = nil

    post = posts(:one)
    post.destroy!

    event = Event.last

    assert_equal @organization.system_user, event.creator
  end

  # Test event organization
  test "events are associated with correct organization" do
    post = Post.create!(
      title: "Test Post",
      body: "Body",
      author: @user,
      category: categories(:one),
      post_status: post_statuses(:open)
    )

    event = Event.last

    assert_equal @organization, event.organization
  end

  # Test polymorphic eventable association
  test "events have correct eventable for different model types" do
    # Clear existing events to make sure we're testing the right ones
    Event.delete_all

    post = Post.create!(
      title: "Test Post",
      body: "Body",
      author: @user,
      category: categories(:one),
      post_status: post_statuses(:open)
    )
    post_event = Event.where(action: "post_created").last

    comment = Comment.create!(
      body: "Test Comment",
      creator: @user,
      post: post
    )
    comment_event = Event.where(action: "comment_created").last

    category = Category.create!(
      name: "Test Category",
      color: "#123456"
    )
    category_event = Event.where(action: "category_created").last

    assert_equal post, post_event.eventable
    assert_equal "Post", post_event.eventable_type

    assert_equal comment, comment_event.eventable
    assert_equal "Comment", comment_event.eventable_type

    assert_equal category, category_event.eventable
    assert_equal "Category", category_event.eventable_type
  end

  # Test that events belong to the eventable
  test "eventable has_many events" do
    post = posts(:one)

    # Create some events for this post
    post.update!(title: "Title 1")
    post.update!(title: "Title 2")
    post.update!(title: "Title 3")

    assert_operator post.events.count, :>=, 3
    assert_includes post.events.pluck(:action), "post_updated"
  end

  # Test track_event with custom particulars
  test "can track events with custom particulars" do
    post = posts(:one)

    post.track_event(:published, particulars: { notify_subscribers: true, priority: "high" })

    event = Event.last

    assert_equal "post_published", event.action
    assert_equal({ "notify_subscribers" => true, "priority" => "high" }, event.particulars)
  end

  test "can track events with custom creator" do
    post = posts(:one)
    custom_creator = users(:one)

    post.track_event(:reviewed, creator: custom_creator)

    event = Event.last

    assert_equal "post_reviewed", event.action
    assert_equal custom_creator, event.creator
  end
end
