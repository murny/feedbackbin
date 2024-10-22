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
end
