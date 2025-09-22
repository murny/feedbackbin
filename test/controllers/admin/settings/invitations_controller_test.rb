# frozen_string_literal: true

require "test_helper"

module Admin
  module Settings
    class InvitationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        sign_in_as @admin
      end

      test "should get new" do
        get new_admin_settings_invitation_url

        assert_response :success
      end

      test "should not get new if not an admin" do
        sign_in_as users(:two)

        get new_admin_settings_invitation_url

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end

      test "admin can create invitation" do
        assert_difference "Invitation.count", 1 do
          post admin_settings_invitations_url, params: { invitation: { email: "new@example.com", name: "New User" } }
        end

        assert_redirected_to admin_settings_invitations_path
        assert_equal "Invitation was successfully created.", flash[:notice]
      end

      test "renders 422 on invalid create" do
        assert_no_difference "Invitation.count" do
          post admin_settings_invitations_url, params: { invitation: { email: "", name: "" } }
        end

        assert_response :unprocessable_entity
      end

      test "non-admin cannot create" do
        sign_in_as users(:two)

        post admin_settings_invitations_url, params: { invitation: { email: "x@example.com", name: "X" } }

        assert_response :redirect
        assert_equal I18n.t("unauthorized"), flash[:alert]
      end
    end
  end
end
