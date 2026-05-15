# frozen_string_literal: true

require "test_helper"

class ModelSortableTest < ActiveSupport::TestCase
  test "sort_by_params orders by a valid column and direction" do
    assert_equal Idea.order(title: :asc).to_a, Idea.sort_by_params("title", "asc").to_a
  end

  test "sort_by_params falls back to created_at for an invalid column" do
    assert_equal Idea.order(created_at: :desc).to_a, Idea.sort_by_params("evil_column_name", "desc").to_a
  end

  test "sort_by_params uses created_at when column is blank" do
    assert_equal Idea.order(created_at: :desc).to_a, Idea.sort_by_params("", "desc").to_a
  end

  test "sort_by_params uses created_at when column is nil" do
    assert_equal Idea.order(created_at: :asc).to_a, Idea.sort_by_params(nil, "asc").to_a
  end

  test "sortable_columns returns all column names by default" do
    assert_equal Idea.columns.map(&:name), Idea.sortable_columns
  end
end
