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

  test "deleting status nullifies ideas using it" do
    status = statuses(:in_progress)
    idea = ideas(:three) # Uses in_progress status

    assert_equal status, idea.status

    assert_difference "Status.count", -1 do
      status.destroy
    end

    # Idea should now have nil status (which means "Open")
    idea.reload

    assert_nil idea.status
    assert_predicate idea, :open?
  end

  test "can delete status without ideas" do
    status = Status.create!(
      name: "Deletable",
      color: "#FF0000",
      position: 100
    )

    assert_difference "Status.count", -1 do
      status.destroy
    end
  end

  test "ordered scope returns statuses in position order" do
    statuses = Status.ordered.pluck(:name)

    # Note: "Open" is now nil status, so not in the list
    assert_equal [ "Planned", "In Progress", "Complete", "Closed" ], statuses
  end

  test "visible_on_idea scope returns only statuses with show_on_idea true" do
    idea_statuses = Status.visible_on_idea.pluck(:name)

    # Based on fixtures: Planned, In Progress show on idea
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

    # Closed should not be included
    assert_not_includes roadmap_statuses, "Closed"
  end
end
