# frozen_string_literal: true

require "test_helper"

class OrganizationInvitationPolicyTest < ActiveSupport::TestCase
  def setup
    @organization_invitation = organization_invitations(:one)
    @user_membership = memberships(:feedbackbin_regular_user_one)
    @admin_membership = memberships(:feedbackbin_admin)
  end

  test "organization invitation new available if admin" do
    assert_not_predicate OrganizationInvitationPolicy.new(nil, @organization_invitation), :new?
    assert_not_predicate OrganizationInvitationPolicy.new(@user_membership, @organization_invitation), :new?

    assert_predicate OrganizationInvitationPolicy.new(@admin_membership, @organization_invitation), :new?
  end

  test "organization invitation create available if admin" do
    assert_not_predicate OrganizationInvitationPolicy.new(nil, @organization_invitation), :create?
    assert_not_predicate OrganizationInvitationPolicy.new(@user_membership, @organization_invitation), :create?

    assert_predicate OrganizationInvitationPolicy.new(@admin_membership, @organization_invitation), :create?
  end
end
