# frozen_string_literal: true

require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = categories(:one)
  end

  test "valid category" do
    assert_predicate @category, :valid?
  end

  test "invalid without name" do
    @category.name = nil

    assert_not @category.valid?
    assert_equal "can't be blank", @category.errors[:name].first
  end

  test "invalid if name taken" do
    duplicate = Category.new(name: @category.name, color: "#3b82f6")

    assert_not duplicate.valid?
    assert_equal "has already been taken", duplicate.errors[:name].first
  end

  # Color validations
  test "invalid without color" do
    @category.color = nil

    assert_not @category.valid?
    assert_includes @category.errors[:color], "can't be blank"
  end

  test "invalid with malformed color" do
    @category.color = "blue"

    assert_not @category.valid?
    assert_includes @category.errors[:color], "must be a valid hex color code"
  end

  test "invalid with short hex color" do
    @category.color = "#fff"

    assert_not @category.valid?
    assert_includes @category.errors[:color], "must be a valid hex color code"
  end

  test "invalid with description over 500 characters" do
    @category.description = "a" * 501

    assert_not @category.valid?
    assert_includes @category.errors[:description], "is too long (maximum is 500 characters)"
  end

  # Scopes
  test "ordered scope returns categories alphabetically" do
    Category.create!(name: "Zebra", color: "#3b82f6")
    Category.create!(name: "Alpha", color: "#10b981")

    ordered = Category.ordered

    assert_equal "Alpha", ordered.first.name
    assert_equal "Zebra", ordered.last.name
  end

  # Dependent restrict_with_error
  test "cannot delete category with posts" do
    category = categories(:one)
    # Create a post with this category
    post = Post.create!(
      title: "Test Post",
      category: category,
      author: users(:one),
      post_status: post_statuses(:one)
    )

    assert_raises(ActiveRecord::DeleteRestrictionError) do
      category.destroy
    end

    assert Category.exists?(category.id)
  end
end
