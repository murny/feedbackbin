# frozen_string_literal: true

require "test_helper"

class UserConnectedAccountTest < ActiveSupport::TestCase
  setup do
    @user_connected_account = user_connected_accounts(:shane_google)
  end

  test "valid user_connected_account" do
    assert_predicate @user_connected_account, :valid?
  end

  test "invalid without provider_name" do
    @user_connected_account.provider_name = nil

    assert_not_predicate @user_connected_account, :valid?
    assert_equal "can't be blank", @user_connected_account.errors[:provider_name].first
  end

  test "invalid without provider_uid" do
    @user_connected_account.provider_uid = nil

    assert_not_predicate @user_connected_account, :valid?
    assert_equal "can't be blank", @user_connected_account.errors[:provider_uid].first
  end

  test "invalid without user" do
    @user_connected_account.user = nil

    assert_not_predicate @user_connected_account, :valid?
    assert_equal "must exist", @user_connected_account.errors[:user].first
  end

  test "invalid if provider_uid taken already for provider_name" do
    user_connected_account = UserConnectedAccount.new(
      provider_name: @user_connected_account.provider_name,
      provider_uid: @user_connected_account.provider_uid,
      user: users(:one)
    )

    assert_not_predicate user_connected_account, :valid?
    assert_equal "has already been taken", user_connected_account.errors[:provider_uid].first
  end

  test "invalid if user already has connected account for provider_name" do
    user_connected_account = UserConnectedAccount.new(
      provider_name: @user_connected_account.provider_name,
      provider_uid: "new_uid",
      user: @user_connected_account.user
    )

    assert_not_predicate user_connected_account, :valid?
    assert_equal "has already been taken", user_connected_account.errors[:user].first
  end
end
