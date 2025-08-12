# frozen_string_literal: true

require "test_helper"

class PostsHelperTest < ActionView::TestCase
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

    link = posts_sort_link("Latest", "created_at", "desc", test_params)

    assert_includes link, "Latest"
    assert_includes link, "bg-primary text-primary-foreground"
  end

  test "sort_link preserves existing params" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc",
      category_id: "5",
      post_status_id: "3"
    })

    link = posts_sort_link("Top", "likes_count", "desc", test_params)

    assert_includes link, "category_id=5"
    assert_includes link, "post_status_id=3"
  end
end
