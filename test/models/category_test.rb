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

  test "invalid without an organization" do
    @category.organization = nil

    assert_not @category.valid?
    assert_equal "must exist", @category.errors[:organization].first
  end

  test "invalid if name taken in same organization" do
    duplicate = Category.new(name: @category.name, organization: @category.organization)

    assert_not duplicate.valid?
    assert_equal "has already been taken", duplicate.errors[:name].first
  end

  test "valid if same name in different organization" do
    category = Category.new(name: @category.name, organization: organizations(:company))

    assert_predicate category, :valid?
  end
end
