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

  test "private roadmap redirects unauthenticated users to sign in" do
    accounts(:feedbackbin).update!(roadmap_public: false)

    get roadmap_url

    assert_redirected_to sign_in_url
  end

  test "private roadmap allows admin access" do
    accounts(:feedbackbin).update!(roadmap_public: false)
    sign_in_as users(:shane)

    get roadmap_url

    assert_response :success
  end

  test "private roadmap returns forbidden for regular members" do
    accounts(:feedbackbin).update!(roadmap_public: false)
    sign_in_as users(:john)

    get roadmap_url

    assert_response :forbidden
  end

  test "displays ideas in their status columns" do
    sign_in_as users(:shane)

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
    sign_in_as users(:shane)

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

  test "card renders creator avatar" do
    sign_in_as users(:shane)
    ideas(:one).update!(status: statuses(:planned))

    get roadmap_url

    assert_response :success
    assert_match(/<img[^>]+class="avatar avatar--xs"/, response.body)
  end

  test "card renders vote count with arrow-up icon" do
    sign_in_as users(:shane)
    ideas(:one).update!(status: statuses(:planned))

    get roadmap_url

    assert_response :success
    assert_match(/<svg[^>]*>[^<]*<path d="m5 12 7-7 7 7">/, response.body)
  end

  test "card renders comment count with message-square icon" do
    sign_in_as users(:shane)
    ideas(:one).update!(status: statuses(:planned))

    get roadmap_url

    assert_response :success
    assert_match(/<path d="M22 17a2 2 0 0 1-2 2H6\.828/, response.body)
  end

  test "card includes board badge" do
    sign_in_as users(:shane)
    ideas(:one).update!(status: statuses(:planned), board: boards(:one))

    get roadmap_url

    assert_response :success
    assert_select "article.panel .badge"
    assert_match(/#{Regexp.escape(boards(:one).name)}/, response.body)
  end

  test "column header renders status dot via BadgeComponent with_dot" do
    get roadmap_url

    assert_response :success
    assert_select ".roadmap-column__header .badge.badge--with-dot"
  end

  test "column header renders idea count without parentheses" do
    sign_in_as users(:shane)
    ideas(:one).update!(status: statuses(:planned))

    get roadmap_url

    assert_response :success
    headers = css_select(".roadmap-column__header").map(&:to_html).join

    assert_no_match(/\(\s*\d+\s*\)/, headers, "Column headers should not wrap counts in parentheses")
  end
end
