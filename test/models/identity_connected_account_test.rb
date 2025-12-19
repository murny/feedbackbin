# frozen_string_literal: true

require "test_helper"

class IdentityConnectedAccountTest < ActiveSupport::TestCase
  setup do
    @identity_connected_account = identity_connected_accounts(:shane_google)
  end

  test "valid identity_connected_account" do
    assert_predicate @identity_connected_account, :valid?
  end

  test "invalid without provider_name" do
    @identity_connected_account.provider_name = nil

    assert_not_predicate @identity_connected_account, :valid?
    assert_equal "can't be blank", @identity_connected_account.errors[:provider_name].first
  end

  test "invalid without provider_uid" do
    @identity_connected_account.provider_uid = nil

    assert_not_predicate @identity_connected_account, :valid?
    assert_equal "can't be blank", @identity_connected_account.errors[:provider_uid].first
  end

  test "invalid without identity" do
    @identity_connected_account.identity = nil

    assert_not_predicate @identity_connected_account, :valid?
    assert_equal "must exist", @identity_connected_account.errors[:identity].first
  end

  test "invalid if provider_uid taken already for provider_name" do
    identity_connected_account = IdentityConnectedAccount.new(
      provider_name: @identity_connected_account.provider_name,
      provider_uid: @identity_connected_account.provider_uid,
      identity: identities(:jane)
    )

    assert_not_predicate identity_connected_account, :valid?
    assert_equal "has already been taken", identity_connected_account.errors[:provider_uid].first
  end

  test "invalid if identity already has connected account for provider_name" do
    identity_connected_account = IdentityConnectedAccount.new(
      provider_name: @identity_connected_account.provider_name,
      provider_uid: "new_uid",
      identity: @identity_connected_account.identity
    )

    assert_not_predicate identity_connected_account, :valid?
    assert_equal "has already been taken", identity_connected_account.errors[:identity].first
  end
end
