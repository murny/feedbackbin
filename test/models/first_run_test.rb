# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Organization.destroy_all
    Membership.destroy_all
    Category.destroy_all
    User.destroy_all
  end

  test "creating makes first user an administrator and sets up a new category and organization" do
    assert_difference "Category.count" do
      assert_difference "User.count" do
        assert_difference "Organization.count" do
          assert_difference "Membership.count" do
            first_run = FirstRun.create!(
              username: "owner_example",
              email_address: "owner@example.com",
              password: "secret123456",
              organization_name: "Test Organization",
              organization_subdomain: "testorg",
              category_name: "Test Category"
            )
            organization = first_run.organization

            assert_predicate organization.memberships.first, :administrator?
            assert_equal "Test Organization", organization.name
            assert_equal "Test Category", organization.categories.first.name
            assert_equal "owner@example.com", first_run.user.email_address
            assert_equal first_run.user.email_address, organization.owner.email_address
          end
        end
      end
    end
  end

  test "validates required fields" do
    first_run = FirstRun.new

    assert_not first_run.valid?
    assert_includes first_run.errors[:username], "can't be blank"
    assert_includes first_run.errors[:email_address], "can't be blank"
    assert_includes first_run.errors[:password], "can't be blank"
    assert_includes first_run.errors[:organization_name], "can't be blank"
    assert_includes first_run.errors[:organization_subdomain], "can't be blank"
  end
end
