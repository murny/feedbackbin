# frozen_string_literal: true

require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get roadmap_url

    assert_response :success
  end

  test "displays only roadmap-visible statuses" do
    get roadmap_url

    assert_response :success
    # Only statuses with show_on_roadmap: true should appear
    Status.visible_on_roadmap.each do |status|
      # Each roadmap-visible status should appear as a heading in the page
      assert_select "h2", text: status.name
    end

    # Statuses NOT visible on roadmap should not appear
    Status.where(show_on_roadmap: false).each do |status|
      assert_select "h2", { text: status.name, count: 0 }
    end
  end

  test "displays ideas in their status columns" do
    planned_status = statuses(:planned)
    idea = ideas(:one)
    idea.update!(status: planned_status, title: "Unique Test Idea Title")

    get roadmap_url

    assert_response :success
    # Verify the status name appears
    assert_match(/#{Regexp.escape(planned_status.name)}/, response.body)
    # Verify the idea title appears
    assert_match(/#{Regexp.escape(idea.title)}/, response.body)
  end

  test "displays ideas ordered by created_at desc" do
    status = statuses(:planned)  # Use a roadmap-visible status

    # Update existing ideas to have specific timestamps and titles
    old_idea = ideas(:one)
    old_idea.update!(
      status: status,
      title: "Older Idea",
      created_at: 2.days.ago
    )

    new_idea = ideas(:two)
    new_idea.update!(
      status: status,
      title: "Newer Idea",
      created_at: 1.day.ago
    )

    get roadmap_url

    assert_response :success
    # Verify both ideas appear
    assert_match(/Newer Idea/, response.body)
    assert_match(/Older Idea/, response.body)
    # Newer idea should appear before older idea in HTML
    assert_operator response.body.index("Newer Idea"), :<, response.body.index("Older Idea")
  end
end
