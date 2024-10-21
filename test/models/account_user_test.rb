# frozen_string_literal: true

require "test_helper"

class AccountUserTest < ActiveSupport::TestCase
  setup do
    @regular_account_user = account_users(:company_regular_user)
  end

  test "valid account user" do
    assert_predicate @regular_account_user, :valid?
  end

  # test invalidate if  user not presence
  test "invalid without user" do
    @regular_account_user.user = nil

    assert_not_predicate @regular_account_user, :valid?
    assert_equal "must exist", @regular_account_user.errors[:user].first
  end

  # test invalidate if  account not presence
  test "invalid without account" do
    @regular_account_user.account = nil

    assert_not_predicate @regular_account_user, :valid?
    assert_equal "must exist", @regular_account_user.errors[:account].first
  end

  # test invalid if user is duplicated on same account
  test "invalid if user is duplicated on same account" do
    new_account_user = AccountUser.new(account: @regular_account_user.account, user: @regular_account_user.user)

    assert_not_predicate new_account_user, :valid?
    assert_equal "has already been taken", new_account_user.errors[:user].first
  end

  test "account_owner?" do
    assert_not_predicate @regular_account_user, :account_owner?

    owner = account_users(:company_admin)

    assert_predicate owner, :account_owner?
  end

  # test validates owner_must_be_administrator
  test "invalid if removing owner as administrator" do
    owner = account_users(:company_admin)

    owner.role = :member

    assert_not_predicate owner, :valid?
    assert_equal "administrator role cannot be removed for the account owner", owner.errors[:role].first
  end
end
