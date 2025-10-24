# frozen_string_literal: true

require "test_helper"

class PostsSortHelperTest < ActionView::TestCase
  test "sort_active_state returns true for latest when no sort params" do
    test_params = ActionController::Parameters.new({ direction: nil })

    assert posts_sort_active_state("created_at", "desc", test_params)
  end

  test "sort_active_state returns true for top with likes_count desc" do
    test_params = ActionController::Parameters.new({ sort: "likes_count", direction: "desc" })

    assert posts_sort_active_state("likes_count", "desc", test_params)
  end

  test "sort_active_state returns false for inactive sort type" do
    test_params = ActionController::Parameters.new({ sort: "created_at", direction: "desc" })

    refute posts_sort_active_state("likes_count", "desc", test_params)
  end

  test "sort_link generates link with active styling" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc",
      category_id: nil,
      post_status_id: nil
    })

    link = posts_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params)

    assert_includes link, "Latest"
    assert_includes link, "bg-primary text-primary-foreground"
  end

  test "sort_link preserves existing params" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc",
      category_id: "5",
      post_status_id: "3",
      search: "feature"
    })

    link = posts_sort_link(text: "Top", sort_field: "likes_count", direction: "desc", params: test_params)

    assert_includes link, "category_id=5"
    assert_includes link, "post_status_id=3"
    assert_includes link, "search=feature"
  end

  test "sort_link uses custom path_helper when provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = posts_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params, path_helper: :roadmap_path)

    assert_includes link, 'href="/roadmap?direction=desc&amp;sort=created_at"'
    assert_includes link, "Latest"
  end

  test "sort_link defaults to posts_path when no path_helper provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = posts_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params)

    assert_includes link, 'href="/posts?direction=desc&amp;sort=created_at"'
    assert_includes link, "Latest"
  end

  test "sort_link includes turbo_frame data attribute when provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = posts_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params, turbo_frame: "posts_content")

    assert_includes link, 'data-turbo-frame="posts_content"'
    assert_includes link, "Latest"
  end

  test "clean_params removes nil and blank values" do
    params = clean_params(sort: "created_at", direction: "", search: nil, category_id: "7")

    assert_equal({ sort: "created_at", category_id: "7" }, params)
  end
end
