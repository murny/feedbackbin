# frozen_string_literal: true

require "test_helper"

class PostStatusTest < ActiveSupport::TestCase
  def setup
    @post_status = post_statuses(:complete)
  end

  test "valid post_status" do
    assert_predicate @post_status, :valid?
  end

  test "invalid without name" do
    @post_status.name = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:name].first
  end

  test "invalid without position" do
    @post_status.position = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:position].first
  end

  test "invalid if position is not an integer" do
    @post_status.position = 1.5

    assert_not @post_status.valid?
    assert_equal "must be an integer", @post_status.errors[:position].first
  end

  test "invalid without color" do
    @post_status.color = nil

    assert_not @post_status.valid?
    assert_equal "can't be blank", @post_status.errors[:color].first
  end

  test "invalid if color is not in the correct format" do
    @post_status.color = "red"

    assert_not @post_status.valid?
    assert_equal "is invalid", @post_status.errors[:color].first
  end

  test "cannot delete status with posts attached" do
    status = post_statuses(:in_progress)

    # Post fixtures already use this status
    assert_predicate(status.posts, :any?)

    # Attempt to destroy should fail
    assert_no_difference "PostStatus.count" do
      status.destroy
    end

    assert_equal "Cannot delete record because dependent posts exist", status.errors[:base].first
  end

  test "cannot delete status used as organization default" do
    default_status = PostStatus.default

    # Delete posts associated with the default status first
    Post.where(post_status: default_status).destroy_all

    assert_no_difference "PostStatus.count" do
      default_status.destroy
    end

    assert_equal "Cannot delete the default status. Reassign default to another status first.", default_status.errors[:base].first
  end

  test "can delete non-default status without posts" do
    # Create a new status that's not the default and has no posts
    status = PostStatus.create!(
      name: "Deletable",
      color: "#FF0000",
      position: 100
    )

    assert_difference "PostStatus.count", -1 do
      status.destroy
    end
  end

  test "default scope returns organization's default status" do
    default_status = PostStatus.default

    assert_not_nil default_status
    assert_equal organizations(:feedbackbin).default_post_status, default_status
    assert_equal "Open", default_status.name
  end

  test "ordered scope returns statuses in position order" do
    statuses = PostStatus.ordered.pluck(:name)

    assert_equal [ "Open", "Planned", "In Progress", "Complete", "Closed" ], statuses
  end
end
