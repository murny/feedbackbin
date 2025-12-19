# frozen_string_literal: true

require "test_helper"

module Admin
  module Users
    class RolesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        sign_in_as @admin
      end

      test "should update user role to admin" do
        user = users(:jane)

        assert_predicate user, :member?, "User should start as member"

        patch admin_user_role_path(user), params: { role: "admin" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :admin?, "User should be admin"
      end

      test "should update user role to member" do
        user = users(:jane)
        user.update!(role: :admin)

        assert_predicate user, :admin?, "User should start as admin"

        patch admin_user_role_path(user), params: { role: "member" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :member?, "User should be member"
      end

      test "should update user role to bot" do
        user = users(:jane)

        assert_predicate user, :member?, "User should start as member"

        patch admin_user_role_path(user), params: { role: "bot" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :bot?, "User should be bot"
      end

      test "should reject invalid role param" do
        user = users(:jane)

        assert_predicate user, :member?, "User should start as member"

        patch admin_user_role_path(user), params: { role: "invalid_role" }

        assert_redirected_to admin_user_path(user)
        assert_equal I18n.t("admin.users.roles.update.invalid_role"), flash[:alert]
        assert_predicate user.reload, :member?, "User should remain member"
      end

      test "should not update account owner role" do
        owner = users(:shane)

        patch admin_user_role_path(owner), params: { role: "member" }

        assert_redirected_to admin_user_path(owner)
        assert_equal "Role cannot be changed for account owner", flash[:alert]
        assert_predicate owner.reload, :owner?, "Owner should remain owner"
      end

      test "should require admin for role management" do
        sign_out
        sign_in_as users(:jane)

        user = users(:john)
        patch admin_user_role_path(user), params: { role: "admin" }

        assert_redirected_to root_path
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end
    end
  end
end
