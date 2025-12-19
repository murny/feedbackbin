# frozen_string_literal: true

require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  setup do
    @invitation = invitations(:one)
  end

  test "valid invitation" do
    assert_predicate @invitation, :valid?
  end

  test "invalid without email" do
    @invitation.email = nil

    assert_not @invitation.valid?
    assert_equal "can't be blank", @invitation.errors[:email].first
  end

  test "invalid without name" do
    @invitation.name = nil

    assert_not @invitation.valid?
    assert_equal "can't be blank", @invitation.errors[:name].first
  end

  test "invalid without invited_by" do
    @invitation.invited_by = nil

    assert_not @invitation.valid?
    assert_equal "must exist", @invitation.errors[:invited_by].first
  end

  test "cannot invite same email twice" do
    invitation = Invitation.create(name: "whatever", email: @invitation.email)

    assert_not invitation.valid?
    assert_equal "has already been invited", invitation.errors[:email].first
  end

  test "#accept!" do
    identity = Identity.create!(
      email_address: @invitation.email,
      password: "password1234"
    )
    user = User.create!(
      name: @invitation.name,
      identity: identity
    )

    assert_difference "Invitation.count", -1 do
      @invitation.accept!(user)
    end

    assert_predicate user.identity.reload, :email_verified?
  end

  test "#reject!" do
    assert_difference "Invitation.count", -1 do
      @invitation.reject!
    end
  end
end
