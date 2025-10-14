# frozen_string_literal: true

require "test_helper"

class RoadmapControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get roadmap_url

    assert_response :success
  end

  test "displays all post statuses" do
    get roadmap_url

    assert_response :success
    PostStatus.ordered.each do |status|
      # Each status should appear as a heading in the page
      assert_select "h2", text: status.name
    end
  end

  test "displays posts in their status columns" do
    open_status = post_statuses(:open)
    post = posts(:one)
    post.update!(post_status: open_status, title: "Unique Test Post Title")

    get roadmap_url

    assert_response :success
    # Verify the status name appears
    assert_match(/#{Regexp.escape(open_status.name)}/, response.body)
    # Verify the post title appears
    assert_match(/#{Regexp.escape(post.title)}/, response.body)
  end

  test "displays posts ordered by created_at desc" do
    status = post_statuses(:open)

    # Update existing posts to have specific timestamps and titles
    old_post = posts(:one)
    old_post.update!(
      post_status: status,
      title: "Older Post",
      created_at: 2.days.ago
    )

    new_post = posts(:two)
    new_post.update!(
      post_status: status,
      title: "Newer Post",
      created_at: 1.day.ago
    )

    get roadmap_url

    assert_response :success
    # Verify both posts appear
    assert_match(/Newer Post/, response.body)
    assert_match(/Older Post/, response.body)
    # Newer post should appear before older post in HTML
    assert_operator response.body.index("Newer Post"), :<, response.body.index("Older Post")
  end
end
