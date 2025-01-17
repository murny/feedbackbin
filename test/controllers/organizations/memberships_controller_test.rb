# frozen_string_literal: true

require "test_helper"

module Organizations
  class MembershipsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin_membership = memberships(:feedbackbin_admin)
      @normal_membership = memberships(:feedbackbin_regular_user_one)
      @user = @admin_membership.user
      @organization = @admin_membership.organization

      sign_in @user
    end

    test "should get index" do
      get organization_memberships_url(@organization)

      assert_response :success
      assert_match @user.email_address, response.body
    end

    test "should not get index if not a member" do
      # user is not a member of the organization
      get organization_memberships_url(organizations(:other_organization))

      assert_response :not_found
    end

    test "should get edit" do
      get edit_organization_membership_url(@organization, @normal_membership)

      assert_response :success
    end

    test "should not get edit if not an admin" do
      sign_in @normal_membership.user

      get edit_organization_membership_url(@organization, @normal_membership)

      assert_response :redirect
    end

    test "should update membership" do
      patch organization_membership_url(@organization, @normal_membership), params: { membership: { role: "administrator" } }

      assert_redirected_to organization_memberships_url
      assert_predicate @normal_membership.reload, :administrator?
    end

    test "should not update membership if not an admin" do
      sign_in @normal_membership.user

      patch organization_membership_url(@organization, @normal_membership), params: { membership: { role: "administrator" } }

      assert_redirected_to root_url
      assert_predicate @normal_membership.reload, :member?
    end

    test "should not update membership if admin is an owner" do
      patch organization_membership_url(@organization, @admin_membership), params: { membership: { role: "member" } }

      assert_response :unprocessable_entity
      assert_predicate @admin_membership.reload, :administrator?
      assert_match "administrator role cannot be removed for the organization owner", response.body
    end

    test "should destroy membership" do
      assert_difference("Membership.count", -1) do
        delete organization_membership_url(@organization, @normal_membership)
      end

      assert_redirected_to organization_memberships_url
      follow_redirect!

      assert_response :success
    end

    test "should not destroy membership if not an admin" do
      sign_in @normal_membership.user

      assert_no_difference("Membership.count") do
        delete organization_membership_url(@organization, @admin_membership)
      end

      assert_redirected_to root_url
    end

    test "should be able to remove their own membership" do
      sign_in @normal_membership.user

      assert_difference("Membership.count", -1) do
        delete organization_membership_url(@organization, @normal_membership)
      end

      assert_redirected_to organizations_url
      follow_redirect!

      assert_response :success
    end

    # TODO: This is currently not implemented
    # test "should not destroy membership if admin is an owner" do
    #   assert_no_difference("Membership.count") do
    #     delete organization_membership_url(@organization, @admin_membership)
    #   end

    #   assert_redirected_to organization_memberships_url
    # end
  end
end
