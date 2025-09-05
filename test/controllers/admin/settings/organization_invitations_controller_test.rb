# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class OrganizationInvitationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        sign_in_as @admin
      end

      test "should get new" do
        get new_admin_settings_organization_invitation_url

        assert_response :success
      end

      test "should not get new if not an admin" do
        sign_in_as users(:two)

        get new_admin_settings_membership_url

        assert_response :not_found
      end

      # TODO: Add tests for creating organization invitations
    end
  end
end
