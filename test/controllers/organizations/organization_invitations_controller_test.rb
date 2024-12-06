# frozen_string_literal: true

require "test_helper"

module Organizations
  class OrganizationInvitationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      @normal_user = users(:one)
      @organization = organizations(:feedbackbin)
      sign_in @admin
    end

    test "should get new" do
      get new_organization_organization_invitation_path(@organization)

      assert_response :success
    end

    test "should not get new if not an admin" do
      sign_in @normal_user
      get new_organization_membership_url(@organization)

      assert_response :not_found
    end

    # TODO: Not yet implemented
    #
    #
    #
    # test "should create invitation" do
    #   email = "new_user@example.com"
    #
    #   # nil email
    #   assert_no_difference("User.count") do
    #     assert_no_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization), params: {organization_invitation: {email: nil}}
    #     end
    #   end
    #   assert_response :unprocessable_entity

    #   assert_no_difference("User.count") do
    #     assert_no_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization)
    #     end
    #   end
    #   assert_response :unprocessable_entity

    #   # invalid email
    #   assert_no_difference("User.count") do
    #     assert_no_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization), params: {organization_invitation: {email: "foo"}}
    #     end
    #   end
    #   assert_response :unprocessable_entity

    #   # missing role
    #   assert_no_difference("User.count") do
    #     assert_no_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization), params: {organization_invitation: {email:}}
    #     end
    #   end
    #   assert_response :unprocessable_entity

    #   # success
    #   assert_difference("User.count") do
    #     assert_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization), params: {organization_invitation: {email:, role: "member"}}
    #     end
    #   end

    #   assert_redirected_to organization_organization_invitations_url
    #   assert @organization.users.find_by(email:)

    #   # when user is already a member
    #   assert_no_difference("User.count") do
    #     assert_no_difference("Membership.count") do
    #       post organization_organization_invitations_url(@organization), params: {organization_invitation: {email:}}
    #     end
    #   end
    #   assert_response :unprocessable_entity
    # end
  end
end
