# frozen_string_literal: true

require "test_helper"

class RoadmapHelperTest < ActionView::TestCase
  test "roadmap_grid_classes returns grid-cols-1 for single column" do
    result = roadmap_grid_classes(1)

    assert_equal "grid grid-cols-1 gap-6 pb-4", result
  end

  test "roadmap_grid_classes returns grid-cols-2 for two columns" do
    result = roadmap_grid_classes(2)

    assert_equal "grid grid-cols-2 gap-6 pb-4", result
  end

  test "roadmap_grid_classes returns grid-cols-3 for three columns" do
    result = roadmap_grid_classes(3)

    assert_equal "grid grid-cols-3 gap-6 pb-4", result
  end

  test "roadmap_grid_classes returns flex layout for four columns" do
    result = roadmap_grid_classes(4)

    assert_equal "flex gap-6 overflow-x-auto pb-4", result
  end

  test "roadmap_grid_classes returns flex layout for five or more columns" do
    result = roadmap_grid_classes(5)

    assert_equal "flex gap-6 overflow-x-auto pb-4", result

    result = roadmap_grid_classes(10)

    assert_equal "flex gap-6 overflow-x-auto pb-4", result
  end

  test "roadmap_grid_classes handles edge case of zero columns" do
    result = roadmap_grid_classes(0)
    # Zero or negative should fallback to grid-cols-1
    assert_equal "grid grid-cols-1 gap-6 pb-4", result
  end
end
