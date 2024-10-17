# frozen_string_literal: true

require "test_helper"

class UserIdentityTest < ActiveSupport::TestCase
  setup do
    @user_identity = user_identities(:shane_google)
  end

  test "valid user_identity" do
    assert_predicate @user_identity, :valid?
  end

  test "invalid without provider_name" do
    @user_identity.provider_name = nil

    assert_not_predicate @user_identity, :valid?
    assert_equal "can't be blank", @user_identity.errors[:provider_name].first
  end

  test "invalid without provider_uid" do
    @user_identity.provider_uid = nil

    assert_not_predicate @user_identity, :valid?
    assert_equal "can't be blank", @user_identity.errors[:provider_uid].first
  end

  test "invalid without user" do
    @user_identity.user = nil

    assert_not_predicate @user_identity, :valid?
    assert_equal "must exist", @user_identity.errors[:user].first
  end

  test "invalid if provider_uid taken already for provider_name" do
    user_identity = UserIdentity.new(
      provider_name: @user_identity.provider_name,
      provider_uid: @user_identity.provider_uid,
      user: users(:one)
    )

    assert_not_predicate user_identity, :valid?
    assert_equal "has already been taken", user_identity.errors[:provider_uid].first
  end

  test "invalid if user already has identity for provider_name" do
    user_identity = UserIdentity.new(
      provider_name: @user_identity.provider_name,
      provider_uid: "new_uid",
      user: @user_identity.user
    )

    assert_not_predicate user_identity, :valid?
    assert_equal "has already been taken", user_identity.errors[:user].first
  end
end
