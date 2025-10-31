# frozen_string_literal: true

require "test_helper"

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should show invitation" do
    invitation = invitations(:one)

    get invitation_url(invitation.token)

    assert_response :success
  end

  test "should show expired page for expired invitation" do
    invitation = invitations(:one)
    invitation.update_column(:expires_at, 1.day.ago)

    get invitation_url(invitation.token)

    assert_response :success
    assert_select "h1", I18n.t("invitations.show.expired.heading")
  end

  test "should redirect if invitation already accepted" do
    invitation = invitations(:one)
    invitation.update!(accepted_at: Time.current, accepted_by: users(:shane))

    get invitation_url(invitation.token)

    assert_redirected_to root_path
    assert_equal I18n.t("invitations.show.already_accepted"), flash[:notice]
  end
end
