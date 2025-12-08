# frozen_string_literal: true

require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:feedbackbin)
    @user = users(:shane)
    @post = posts(:one)
    Current.organization = @organization
  end

  test "creates event with required attributes" do
    event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    assert event.persisted?
    assert_equal "post_created", event.action
    assert_equal @user, event.creator
    assert_equal @organization, event.organization
    assert_equal @post, event.eventable
  end

  test "requires action" do
    event = Event.new(
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    assert_not event.valid?
    assert_includes event.errors[:action], "can't be blank"
  end

  test "requires creator" do
    event = Event.new(
      action: "post_created",
      organization: @organization,
      eventable: @post
    )

    assert_not event.valid?
    assert_includes event.errors[:creator], "must exist"
  end

  test "requires organization" do
    # Clear Current.organization so the default doesn't apply
    Current.organization = nil

    event = Event.new(
      action: "post_created",
      creator: @user,
      eventable: @post
    )

    assert_not event.valid?
    assert_includes event.errors[:organization], "must exist"
  ensure
    # Restore for other tests
    Current.organization = @organization
  end

  test "requires eventable" do
    event = Event.new(
      action: "post_created",
      creator: @user,
      organization: @organization
    )

    assert_not event.valid?
    assert_includes event.errors[:eventable], "must exist"
  end

  test "stores particulars as JSON" do
    event = Event.create!(
      action: "post_published",
      creator: @user,
      organization: @organization,
      eventable: @post,
      particulars: { notify_subscribers: true, urgency: "high" }
    )

    assert_equal({ "notify_subscribers" => true, "urgency" => "high" }, event.particulars)
  end

  test "defaults particulars to empty hash" do
    event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    assert_equal({}, event.particulars)
  end

  test "ordered scope returns events in descending order" do
    old_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 2.days.ago
    )

    new_event = Event.create!(
      action: "post_updated",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 1.day.ago
    )

    events = Event.ordered
    assert_equal new_event, events.first
    assert_equal old_event, events.last
  end

  test "for_organization scope filters by organization" do
    other_org = organizations(:feedbackbin)
    event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    events = Event.for_organization(@organization)
    assert_includes events, event
  end

  test "for_eventable scope filters by eventable" do
    post_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    comment = comments(:one)
    comment_event = Event.create!(
      action: "comment_created",
      creator: @user,
      organization: @organization,
      eventable: comment
    )

    post_events = Event.for_eventable(@post)
    assert_includes post_events, post_event
    assert_not_includes post_events, comment_event
  end

  test "by_action scope filters by action" do
    created_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    updated_event = Event.create!(
      action: "post_updated",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    created_events = Event.by_action("post_created")
    assert_includes created_events, created_event
    assert_not_includes created_events, updated_event
  end

  test "recent scope limits to 50 events" do
    60.times do |i|
      Event.create!(
        action: "post_created_#{i}",
        creator: @user,
        organization: @organization,
        eventable: @post
      )
    end

    assert_equal 50, Event.recent.count
  end

  test "cleanup_old deletes events older than 90 days" do
    old_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 91.days.ago
    )

    recent_event = Event.create!(
      action: "post_updated",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 89.days.ago
    )

    Event.cleanup_old

    assert_not Event.exists?(old_event.id)
    assert Event.exists?(recent_event.id)
  end

  test "cleanup_old accepts custom older_than parameter" do
    old_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 31.days.ago
    )

    recent_event = Event.create!(
      action: "post_updated",
      creator: @user,
      organization: @organization,
      eventable: @post,
      created_at: 29.days.ago
    )

    Event.cleanup_old(older_than: 30.days.ago)

    assert_not Event.exists?(old_event.id)
    assert Event.exists?(recent_event.id)
  end

  test "polymorphic association works with different eventable types" do
    post_event = Event.create!(
      action: "post_created",
      creator: @user,
      organization: @organization,
      eventable: @post
    )

    comment = comments(:one)
    comment_event = Event.create!(
      action: "comment_created",
      creator: @user,
      organization: @organization,
      eventable: comment
    )

    category = categories(:one)
    category_event = Event.create!(
      action: "category_created",
      creator: @user,
      organization: @organization,
      eventable: category
    )

    assert_equal @post, post_event.eventable
    assert_equal comment, comment_event.eventable
    assert_equal category, category_event.eventable
  end
end
