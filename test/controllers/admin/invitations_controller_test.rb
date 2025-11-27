# frozen_string_literal: true

require "test_helper"

module Admin
  class InvitationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_invitations_url

      assert_response :success
    end

    test "should not get index if not an admin" do
      sign_in_as users(:two)

      get admin_invitations_url

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end

    test "should get new" do
      get new_admin_invitation_url

      assert_response :success
    end

    test "should not get new if not an admin" do
      sign_in_as users(:two)

      get new_admin_invitation_url

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end

    test "admin can create invitation" do
      assert_difference "Invitation.count", 1 do
        assert_enqueued_emails 1 do
          post admin_invitations_url, params: { invitation: { email: "new@example.com", name: "New User" } }
        end
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.create.successfully_sent"), flash[:notice]
    end

    test "renders 422 on invalid create" do
      assert_no_difference "Invitation.count" do
        post admin_invitations_url, params: { invitation: { email: "", name: "" } }
      end

      assert_response :unprocessable_entity
    end

    test "non-admin cannot create" do
      sign_in_as users(:two)

      post admin_invitations_url, params: { invitation: { email: "x@example.com", name: "X" } }

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end

    test "should resend invitation email" do
      invitation = invitations(:one)
      original_token = invitation.token

      assert_enqueued_emails 1 do
        post resend_admin_invitation_url(invitation.token)
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.resend.resent", email: invitation.email), flash[:notice]
      assert_equal original_token, invitation.reload.token
    end

    test "non-admin cannot resend" do
      sign_in_as users(:two)
      invitation = invitations(:one)

      post resend_admin_invitation_url(invitation.token)

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end

    test "should return 404 for invalid invitation token on resend" do
      post resend_admin_invitation_url("invalid-token")

      assert_response :not_found
    end

    test "should destroy invitation" do
      invitation = invitations(:one)

      assert_difference "Invitation.count", -1 do
        delete admin_invitation_url(invitation.token)
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.destroy.successfully_cancelled"), flash[:notice]
    end

    test "non-admin cannot destroy" do
      sign_in_as users(:two)
      invitation = invitations(:one)

      delete admin_invitation_url(invitation.token)

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end
  end
end
