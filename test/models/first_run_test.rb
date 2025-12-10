# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Organization.destroy_all
  end

  test "creating makes first user an administrator and sets up a new category and organization" do
    assert_difference [ "Category.count", "User.count", "Organization.count" ] do
      first_run = FirstRun.new(
        name: "Owner Example",
        email_address: "owner@example.com",
        password: "secret123456",
        organization_name: "Test Organization",
        category_name: "Test Category",
        category_color: "#3b82f6"
      ).save!

      assert_predicate first_run.user, :administrator?
      assert_equal "Test Organization", first_run.organization.name
      assert_equal "Test Category", first_run.category.name
      assert_equal "Owner Example", first_run.user.name
      assert_equal "owner@example.com", first_run.user.email_address
    end
  end

  test "validates required fields" do
    first_run = FirstRun.new

    assert_not first_run.valid?
    assert_equal "can't be blank", first_run.errors[:name].first
    assert_equal "can't be blank", first_run.errors[:email_address].first
    assert_equal "can't be blank", first_run.errors[:password].first
    assert_equal "can't be blank", first_run.errors[:organization_name].first
    assert_equal "can't be blank", first_run.errors[:category_name].first
    assert_equal "can't be blank", first_run.errors[:category_color].first
  end
end
