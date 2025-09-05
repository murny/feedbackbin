# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class MembershipsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin_membership = memberships(:feedbackbin_admin)
        @normal_membership = memberships(:feedbackbin_regular_user_one)
        @user = @admin_membership.user

        sign_in_as @user
      end

      test "should get index" do
        get admin_settings_memberships_url

        assert_response :success
        assert_match @user.email_address, response.body
      end

      test "should not get index if not an admin" do
        sign_in_as users(:two)

        # user is not a member of the organization
        get admin_settings_memberships_url

        assert_response :redirect
      end

      test "should get edit" do
        get edit_admin_settings_membership_url(@normal_membership)

        assert_response :success
      end

      test "should not get edit if not an admin" do
        sign_in_as users(:two)

        get edit_admin_settings_membership_url(@normal_membership)

        assert_response :redirect
      end

      test "should update membership" do
        patch admin_settings_membership_url(@normal_membership), params: { membership: { role: "administrator" } }

        assert_redirected_to admin_settings_memberships_url
        assert_predicate @normal_membership.reload, :administrator?
      end

      test "should not update membership if not an admin" do
        sign_in_as users(:two)

        patch admin_settings_membership_url(@normal_membership), params: { membership: { role: "administrator" } }

        assert_redirected_to root_url
        assert_predicate @normal_membership.reload, :member?
      end

      test "should not update membership if admin is an owner" do
        patch admin_settings_membership_url(@admin_membership), params: { membership: { role: "member" } }

        assert_response :unprocessable_entity
        assert_predicate @admin_membership.reload, :administrator?
        assert_match "administrator role cannot be removed for the organization owner", response.body
      end

      test "should destroy membership" do
        assert_difference("Membership.count", -1) do
          delete admin_settings_membership_url(@normal_membership)
        end

        assert_redirected_to admin_settings_memberships_url
        follow_redirect!

        assert_response :success
      end

      test "should not destroy membership if not an admin" do
        sign_in_as users(:two)

        assert_no_difference("Membership.count") do
          delete admin_settings_membership_url(@admin_membership)
        end

        assert_redirected_to root_url
      end

      test "should not destroy membership if admin is an owner" do
        assert_no_difference("Membership.count") do
          delete admin_settings_membership_url(@admin_membership)
        end

        assert_redirected_to admin_settings_memberships_url
        assert_equal I18n.t("admin.settings.memberships.destroy.owner_cannot_be_removed"), flash[:alert]
      end
    end
  end
end
