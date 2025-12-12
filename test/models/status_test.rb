# frozen_string_literal: true

require "test_helper"

class StatusTest < ActiveSupport::TestCase
  def setup
    @status = statuses(:complete)
  end

  test "valid status" do
    assert_predicate @status, :valid?
  end

  test "invalid without name" do
    @status.name = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:name].first
  end

  test "invalid without position" do
    @status.position = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:position].first
  end

  test "invalid if position is not an integer" do
    @status.position = 1.5

    assert_not @status.valid?
    assert_equal "must be an integer", @status.errors[:position].first
  end

  test "invalid without color" do
    @status.color = nil

    assert_not @status.valid?
    assert_equal "can't be blank", @status.errors[:color].first
  end

  test "invalid if color is not in the correct format" do
    @status.color = "red"

    assert_not @status.valid?
    assert_equal "is invalid", @status.errors[:color].first
  end

  test "cannot delete status with ideas attached" do
    status = statuses(:in_progress)

    # Idea fixtures already use this status
    assert_predicate(status.ideas, :any?)

    # Attempt to destroy should fail
    assert_no_difference "Status.count" do
      status.destroy
    end

    assert_equal "Cannot delete this status because ideas are still using it. Please reassign or delete those ideas first.", status.errors[:base].first
  end

  test "cannot delete status used as account default" do
    default_status = Status.default

    # Delete ideas associated with the default status first
    Idea.where(status: default_status).destroy_all

    assert_no_difference "Status.count" do
      default_status.destroy
    end

    assert_equal "Cannot delete the default status. Reassign default to another status first.", default_status.errors[:base].first
  end

  test "can delete non-default status without ideas" do
    # Create a new status that's not the default and has no ideas
    status = Status.create!(
      name: "Deletable",
      color: "#FF0000",
      position: 100
    )

    assert_difference "Status.count", -1 do
      status.destroy
    end
  end

  test "default scope returns account's default status" do
    default_status = Status.default

    assert_not_nil default_status
    assert_equal accounts(:feedbackbin).default_status, default_status
    assert_equal "Open", default_status.name
  end

  test "ordered scope returns statuses in position order" do
    statuses = Status.ordered.pluck(:name)

    assert_equal [ "Open", "Planned", "In Progress", "Complete", "Closed" ], statuses
  end

  test "visible_on_idea scope returns only statuses with show_on_idea true" do
    idea_statuses = Status.visible_on_idea.pluck(:name)

    # Based on fixtures: Open, Planned, In Progress show on idea
    assert_includes idea_statuses, "Open"
    assert_includes idea_statuses, "Planned"
    assert_includes idea_statuses, "In Progress"
    # Complete and Closed should not be included
    assert_not_includes idea_statuses, "Complete"
    assert_not_includes idea_statuses, "Closed"
  end

  test "visible_on_roadmap scope returns only statuses with show_on_roadmap true" do
    roadmap_statuses = Status.visible_on_roadmap.pluck(:name)

    # Based on fixtures: Planned, In Progress and Complete get shown on roadmap
    assert_includes roadmap_statuses, "Planned"
    assert_includes roadmap_statuses, "In Progress"
    assert_includes roadmap_statuses, "Complete"

    # Open and Closed should not be included
    assert_not_includes roadmap_statuses, "Open"
    assert_not_includes roadmap_statuses, "Closed"
  end
end
