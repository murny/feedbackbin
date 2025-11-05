# frozen_string_literal: true

require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should show invitation" do
    invitation = invitations(:one)

    get invitation_url(invitation.token)

    assert_response :success
  end

  test "should redirect if invitation not found (already accepted)" do
    # Create and immediately accept (delete) an invitation
    invitation = Invitation.create!(
      email: "test@example.com",
      name: "Test User",
      invited_by: users(:shane)
    )
    user = User.create!(
      username: "testuser",
      email_address: invitation.email,
      name: invitation.name,
      password: "password123",
      password_confirmation: "password123"
    )
    token = invitation.token
    invitation.accept!(user) # Deletes the invitation

    get invitation_url(token)

    assert_redirected_to root_url
    assert_equal I18n.t("invitations.show.not_found"), flash[:alert]
  end

  test "should handle invalid invitation token gracefully" do
    get invitation_url("invalid-token-12345")

    assert_redirected_to root_url
    assert_equal I18n.t("invitations.show.not_found"), flash[:alert]
  end
end
