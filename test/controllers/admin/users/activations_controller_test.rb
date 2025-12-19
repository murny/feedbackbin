# frozen_string_literal: true

require "test_helper"

module Admin
  module Users
    class ActivationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        sign_in_as @admin
      end

      test "should deactivate user" do
        user = users(:jane)

        assert_predicate user, :active?, "User should start as active"

        delete admin_user_activation_path(user)

        assert_redirected_to admin_user_path(user)
        assert_equal "User has been deactivated", flash[:notice]
        assert_not_predicate user.reload, :active?, "User should be deactivated"
      end

      test "should activate user" do
        user = users(:jane)
        user.update!(active: false)

        assert_not_predicate user, :active?, "User should start as deactivated"

        post admin_user_activation_path(user)

        assert_redirected_to admin_user_path(user)
        assert_equal "User has been activated", flash[:notice]
        assert_predicate user.reload, :active?, "User should be active"
      end

      test "should not deactivate account owner" do
        owner = users(:shane)

        assert_predicate owner, :active?, "Owner should start as active"

        delete admin_user_activation_path(owner)

        assert_redirected_to admin_user_path(owner)
        assert_equal "Active account owner cannot be deactivated", flash[:alert]
        assert_predicate owner.reload, :active?, "Owner should remain active"
      end

      test "should require admin for status management" do
        sign_out
        sign_in_as users(:jane)

        user = users(:john)
        delete admin_user_activation_path(user)

        assert_redirected_to root_path
        assert_equal "You are not authorized to perform this action.", flash[:alert]
      end
    end
  end
end
