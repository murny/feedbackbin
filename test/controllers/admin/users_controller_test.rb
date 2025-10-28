# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_users_path

      assert_response :success
      assert_includes @response.body, "Users"
    end

    test "should get index with search" do
      get admin_users_path, params: { search: "shane" }

      assert_response :success
      assert_includes @response.body, "Shane"
    end

    test "should get index as turbo_stream" do
      get admin_users_path, as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
    end

    test "should show user" do
      user = users(:one)
      get admin_user_path(user)

      assert_response :success
      assert_includes @response.body, user.name
    end

    test "should require authentication" do
      sign_out
      get admin_users_path

      assert_redirected_to sign_in_path
    end

    test "should update user role to administrator" do
      user = users(:one)

      assert_predicate user, :member?, "User should start as member"

      patch update_role_admin_user_path(user), params: { role: "administrator" }

      assert_redirected_to admin_user_path(user)
      assert_equal "User role has been updated", flash[:notice]
      assert_predicate user.reload, :administrator?, "User should be administrator"
    end

    test "should update user role to member" do
      user = users(:one)
      user.update!(role: :administrator)

      assert_predicate user, :administrator?, "User should start as administrator"

      patch update_role_admin_user_path(user), params: { role: "member" }

      assert_redirected_to admin_user_path(user)
      assert_equal "User role has been updated", flash[:notice]
      assert_predicate user.reload, :member?, "User should be member"
    end

    test "should update user role to bot" do
      user = users(:one)

      assert_predicate user, :member?, "User should start as member"

      patch update_role_admin_user_path(user), params: { role: "bot" }

      assert_redirected_to admin_user_path(user)
      assert_equal "User role has been updated", flash[:notice]
      assert_predicate user.reload, :bot?, "User should be bot"
    end

    test "should not update organization owner role" do
      owner = users(:shane) # Shane is the organization owner

      patch update_role_admin_user_path(owner), params: { role: "member" }

      # Validation prevents the change and redirects back with error
      assert_redirected_to admin_user_path(owner)
      assert_equal "Role cannot be changed for organization owner", flash[:alert]
      assert_predicate owner.reload, :administrator?, "Owner should remain administrator"
    end

    # Status management tests
    test "should deactivate user" do
      user = users(:one)

      assert_predicate user, :active?, "User should start as active"

      patch deactivate_admin_user_path(user)

      assert_redirected_to admin_user_path(user)
      assert_equal "User has been deactivated", flash[:notice]
      assert_predicate user.reload, :deactivated?, "User should be deactivated"
    end

    test "should activate user" do
      user = users(:one)
      user.update!(active: false)

      assert_predicate user, :deactivated?, "User should start as deactivated"

      patch activate_admin_user_path(user)

      assert_redirected_to admin_user_path(user)
      assert_equal "User has been activated", flash[:notice]
      assert_predicate user.reload, :active?, "User should be active"
    end

    test "should not deactivate organization owner" do
      owner = users(:shane) # Shane is the organization owner

      assert_predicate owner, :active?, "Owner should start as active"

      patch deactivate_admin_user_path(owner)

      # Validation prevents the change and redirects back with error
      assert_redirected_to admin_user_path(owner)
      assert_equal "Active organization owner cannot be deactivated", flash[:alert]
      assert_predicate owner.reload, :active?, "Owner should remain active"
    end

    test "should require admin for role management" do
      sign_out
      sign_in_as users(:one) # Regular member

      user = users(:two)
      patch update_role_admin_user_path(user), params: { role: "administrator" }

      assert_redirected_to root_path # Non-admins are redirected
      assert_equal "You are not authorized to perform this action.", flash[:alert]
    end

    test "should require admin for status management" do
      sign_out
      sign_in_as users(:one) # Regular member

      user = users(:two)
      patch deactivate_admin_user_path(user)

      assert_redirected_to root_path # Non-admins are redirected
      assert_equal "You are not authorized to perform this action.", flash[:alert]
    end
  end
end
