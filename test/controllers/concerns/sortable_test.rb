# frozen_string_literal: true

require "test_helper"

class SortableTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
  end

  test "sort_column defaults to created_at when no sort param is given" do
    get ideas_url

    assert_response :success
    assert_equal "created_at", @controller.sort_column(Idea)
  end

  test "sort_column returns a valid sort column when requested" do
    get ideas_url, params: { sort: "title" }

    assert_equal "title", @controller.sort_column(Idea)
  end

  test "sort_column rejects invalid columns and falls back to created_at" do
    get ideas_url, params: { sort: "drop_table" }

    assert_equal "created_at", @controller.sort_column(Idea)
  end

  test "sort_column honors custom default" do
    get ideas_url

    assert_equal "title", @controller.sort_column(Idea, default: "title")
  end

  test "sort_direction defaults to desc when no direction param is given" do
    get ideas_url

    assert_equal "desc", @controller.sort_direction
  end

  test "sort_direction returns asc when valid" do
    get ideas_url, params: { direction: "asc" }

    assert_equal "asc", @controller.sort_direction
  end

  test "sort_direction rejects invalid direction and falls back to desc" do
    get ideas_url, params: { direction: "sideways" }

    assert_equal "desc", @controller.sort_direction
  end
end
