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
        post admin_invitations_url, params: { invitation: { email: "new@example.com", name: "New User" } }
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

    test "should destroy pending invitation" do
      invitation = invitations(:one)
      invitation.reload

      assert_predicate invitation, :pending?, "Invitation should be pending"

      assert_difference "Invitation.count", -1 do
        delete admin_invitation_url(invitation.id)
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.destroy.successfully_cancelled"), flash[:notice]
    end

    test "should destroy expired invitation" do
      invitation = invitations(:one)
      invitation.update_column(:expires_at, 1.day.ago)
      invitation.reload

      assert_predicate invitation, :expired?, "Invitation should be expired"

      assert_difference "Invitation.count", -1 do
        delete admin_invitation_url(invitation.id)
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.destroy.successfully_cancelled"), flash[:notice]
    end

    test "cannot destroy accepted invitation" do
      invitation = invitations(:one)
      invitation.update!(accepted_at: Time.current, accepted_by: users(:shane))
      invitation.reload

      assert_no_difference "Invitation.count" do
        delete admin_invitation_url(invitation.id)
      end

      assert_redirected_to admin_invitations_path
      assert_equal I18n.t("admin.invitations.destroy.cannot_cancel_accepted"), flash[:alert]
    end

    test "non-admin cannot destroy" do
      sign_in_as users(:two)
      invitation = invitations(:one)

      delete admin_invitation_url(invitation)

      assert_response :redirect
      assert_equal I18n.t("unauthorized"), flash[:alert]
    end
  end
end
