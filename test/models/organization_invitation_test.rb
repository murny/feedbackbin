# frozen_string_literal: true

require "test_helper"

class OrganizationInvitationTest < ActiveSupport::TestCase
  setup do
    @organization_invitation = organization_invitations(:one)
    @organization = @organization_invitation.organization
  end

  test "valid organization invitation" do
    assert_predicate @organization_invitation, :valid?
  end

  test "invalid without email" do
    @organization_invitation.email = nil

    assert_not @organization_invitation.valid?
    assert_equal "can't be blank", @organization_invitation.errors[:email].first
  end

  test "invalid without name" do
    @organization_invitation.name = nil

    assert_not @organization_invitation.valid?
    assert_equal "can't be blank", @organization_invitation.errors[:name].first
  end

  test "invalid without organization" do
    @organization_invitation.organization = nil

    assert_not @organization_invitation.valid?
    assert_equal "must exist", @organization_invitation.errors[:organization].first
  end

  test "invalid without invited_by" do
    @organization_invitation.invited_by = nil

    assert_not @organization_invitation.valid?
    assert_equal "must exist", @organization_invitation.errors[:invited_by].first
  end

  test "cannot invite same email twice" do
    invitation = @organization.organization_invitations.create(name: "whatever", email: @organization_invitation.email)

    assert_not invitation.valid?
  end

  # TODO: This needs to be implemented
  # test "accept" do
  #   user = users(:invited)
  #   assert_difference "Membership.count" do
  #     membership = @organization_invitation.accept!(user)

  #     assert_predicate membership, :persisted?
  #     assert_equal user, membership.user
  #   end

  #   assert_raises ActiveRecord::RecordNotFound do
  #     @organization_invitation.reload
  #   end
  # end

  test "reject" do
    assert_difference "OrganizationInvitation.count", -1 do
      @organization_invitation.reject!
    end
  end
end
