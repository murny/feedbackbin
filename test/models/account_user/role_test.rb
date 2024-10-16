# frozen_string_literal: true

require "test_helper"

class AccountUser::RoleTest < ActiveSupport::TestCase
  setup do
    @account_user = account_users(:company_regular_user)
  end

  test "creating users makes them members by default" do
    assert_predicate AccountUser.create!, :member?
  end

  test "can_administer?" do
    assert_predicate @account_user.role = :administrator, :can_administer?

    assert_not AccountUser.new(role: :member).can_administer?
    assert_not AccountUser.new.can_administer?
  end

  test "Roles must be a valid role" do
    @account_user.role = :super_admin

    assert_not @account_user.valid?
    assert_equal("is not included in the list", @account_user.errors[:role].first)
  end
end
