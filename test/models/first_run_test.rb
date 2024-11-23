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
            organization = FirstRun.create!({username: "owner_example", email_address: "owner@example.com", password: "secret123456"})

            assert_predicate organization.memberships.first, :administrator?
            assert_equal organization.memberships.first.user, organization.owner
            assert_equal "owner@example.com", organization.owner.email_address
          end
        end
      end
    end
  end
end
