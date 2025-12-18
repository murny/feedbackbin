# frozen_string_literal: true

require "test_helper"

class User
  class RoleTest < ActiveSupport::TestCase
    setup do
      @user = users(:one)
    end

    test "creating new users makes them members by default" do
      assert_predicate User.new, :member?
    end

    test "admin?" do
      @user.role = :admin

      assert_predicate @user, :admin?

      assert_not User.new(role: :member).admin?
      assert_not User.new.admin?
    end

    test "Roles must be a valid role" do
      @user.role = :invalid_role

      assert_not @user.valid?
      assert_equal("is not included in the list", @user.errors[:role].first)
    end

    test "cannot change role for account owner" do
      owner = users(:shane)

      assert_not owner.update(role: :member)
      assert_equal "cannot be changed for account owner", owner.errors[:role].first
    end
  end
end
