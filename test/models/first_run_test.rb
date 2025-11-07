# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Organization.destroy_all
  end

  test "creating makes first user an administrator and sets up a new category and organization" do
    assert_difference [ "Category.count", "User.count", "Organization.count" ] do
      first_run = FirstRun.new(
        username: "owner_example",
        email_address: "owner@example.com",
        password: "secret123456",
        organization_name: "Test Organization",
        category_name: "Test Category",
        category_color: "#3b82f6"
      ).save!

      assert_predicate first_run.user, :administrator?
      assert_equal "Test Organization", first_run.organization.name
      assert_equal "Test Category", first_run.category.name
      assert_equal "owner@example.com", first_run.user.email_address
    end
  end

  test "validates required fields" do
    first_run = FirstRun.new

    assert_not first_run.valid?
    assert_includes first_run.errors[:username], "can't be blank"
    assert_includes first_run.errors[:email_address], "can't be blank"
    assert_includes first_run.errors[:password], "can't be blank"
    assert_includes first_run.errors[:organization_name], "can't be blank"
    assert_includes first_run.errors[:category_name], "can't be blank"
    assert_includes first_run.errors[:category_color], "can't be blank"
  end
end
