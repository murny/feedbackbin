# frozen_string_literal: true

require "test_helper"

class OrganizationInvitationTest < ActiveSupport::TestCase
  setup do
    @organization_invitation = organization_invitations(:one)
    @organization = @organization_invitation.organization
  end

  test "cannot invite same email twice" do
    invitation = @organization.organization_invitations.create(name: "whatever", email: @organization_invitation.email)

    assert_not invitation.valid?
  end

  test "accept" do
    user = users(:invited)
    assert_difference "Membership.count" do
      membership = @organization_invitation.accept!(user)

      assert_predicate membership, :persisted?
      assert_equal user, membership.user
    end

    assert_raises ActiveRecord::RecordNotFound do
      @organization_invitation.reload
    end
  end

  test "reject" do
    assert_difference "OrganizationInvitation.count", -1 do
      @organization_invitation.reject!
    end
  end
end
