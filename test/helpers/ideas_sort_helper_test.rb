# frozen_string_literal: true

require "test_helper"

class IdeasSortHelperTest < ActionView::TestCase
  test "sort_active_state returns true for latest when no sort params" do
    test_params = ActionController::Parameters.new({ direction: nil })

    assert ideas_sort_active_state("created_at", "desc", test_params)
  end

  test "sort_active_state returns true for top with votes_count desc" do
    test_params = ActionController::Parameters.new({ sort: "votes_count", direction: "desc" })

    assert ideas_sort_active_state("votes_count", "desc", test_params)
  end

  test "sort_active_state returns false for inactive sort type" do
    test_params = ActionController::Parameters.new({ sort: "created_at", direction: "desc" })

    refute ideas_sort_active_state("votes_count", "desc", test_params)
  end

  test "sort_link generates link with active styling" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc",
      board_id: nil,
      status_id: nil
    })

    link = ideas_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params)

    assert_includes link, "Latest"
    assert_includes link, "bg-primary text-primary-foreground"
  end

  test "sort_link preserves existing params" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc",
      board_id: "5",
      status_id: "3",
      search: "feature"
    })

    link = ideas_sort_link(text: "Top", sort_field: "votes_count", direction: "desc", params: test_params)

    assert_includes link, "board_id=5"
    assert_includes link, "status_id=3"
    assert_includes link, "search=feature"
  end

  test "sort_link uses custom path_helper when provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = ideas_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params, path_helper: :roadmap_path)

    assert_includes link, "href=\"#{Current.account.slug}/roadmap?direction=desc&amp;sort=created_at\""
    assert_includes link, "Latest"
  end

  test "sort_link defaults to ideas_path when no path_helper provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = ideas_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params)

    assert_includes link, "href=\"#{Current.account.slug}/ideas?direction=desc&amp;sort=created_at\""
    assert_includes link, "Latest"
  end

  test "sort_link includes turbo_frame data attribute when provided" do
    test_params = ActionController::Parameters.new({
      sort: "created_at",
      direction: "desc"
    })

    link = ideas_sort_link(text: "Latest", sort_field: "created_at", direction: "desc", params: test_params, turbo_frame: "ideas_content")

    assert_includes link, 'data-turbo-frame="ideas_content"'
    assert_includes link, "Latest"
  end

  test "clean_params removes nil and blank values" do
    params = clean_params(sort: "created_at", direction: "", search: nil, board_id: "7")

    assert_equal({ sort: "created_at", board_id: "7" }, params)
  end
end
