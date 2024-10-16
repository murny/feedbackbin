# frozen_string_literal: true

require "test_helper"

class AccountUser::RoleTest < ActiveSupport::TestCase
  setup do
    @account_user = account_users(:company_regular_user)
  end

  test "creating new users makes them members by default" do
    assert_predicate AccountUser.new(account: @account_user.account, user: @account_user.user), :member?
  end

  test "can_administer?" do
    @account_user.role = :administrator

    assert_predicate @account_user, :can_administer?

    assert_not AccountUser.new(account: @account_user.account, user: @account_user.user, role: :member).can_administer?
    assert_not AccountUser.new(account: @account_user.account, user: @account_user.user).can_administer?
  end

  test "Roles must be a valid role" do
    @account_user.role = :super_admin

    assert_not @account_user.valid?
    assert_equal("is not included in the list", @account_user.errors[:role].first)
  end
end
