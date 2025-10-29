# frozen_string_literal: true

require "test_helper"

module Admin
  module Users
    class RolesControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        sign_in_as @admin
      end

      test "should update user role to administrator" do
        user = users(:one)

        assert_predicate user, :member?, "User should start as member"

        patch admin_user_role_path(user), params: { role: "administrator" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :administrator?, "User should be administrator"
      end

      test "should update user role to member" do
        user = users(:one)
        user.update!(role: :administrator)

        assert_predicate user, :administrator?, "User should start as administrator"

        patch admin_user_role_path(user), params: { role: "member" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :member?, "User should be member"
      end

      test "should update user role to bot" do
        user = users(:one)

        assert_predicate user, :member?, "User should start as member"

        patch admin_user_role_path(user), params: { role: "bot" }

        assert_redirected_to admin_user_path(user)
        assert_equal "User role has been updated", flash[:notice]
        assert_predicate user.reload, :bot?, "User should be bot"
      end

      test "should not update organization owner role" do
        owner = users(:shane)

        patch admin_user_role_path(owner), params: { role: "member" }

        assert_redirected_to admin_user_path(owner)
        assert_equal "Role cannot be changed for organization owner", flash[:alert]
        assert_predicate owner.reload, :administrator?, "Owner should remain administrator"
      end

      test "should require admin for role management" do
        sign_out
        sign_in_as users(:one)

        user = users(:two)
        patch admin_user_role_path(user), params: { role: "administrator" }

        assert_redirected_to root_path
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end
    end
  end
end
