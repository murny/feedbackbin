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

    test "administer?" do
      @user.role = :administrator

      assert_predicate @user, :administrator?

      assert_not User.new(role: :member).administrator?
      assert_not User.new.administrator?
    end

    test "Roles must be a valid role" do
      @user.role = :super_admin

      assert_not @user.valid?
      assert_equal("is not included in the list", @user.errors[:role].first)
    end
  end
end
