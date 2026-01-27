# frozen_string_literal: true

require "test_helper"

class AccountPolicyTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:feedbackbin)
    @user = users(:jane)
    @admin_user = users(:admin)
    @owner_user = users(:shane)
  end

  test "account show viewable by admins" do
    assert_not_predicate AccountPolicy.new(nil, @account), :show?
    assert_not_predicate AccountPolicy.new(@user, @account), :show?

    assert_predicate AccountPolicy.new(@admin_user, @account), :show?
    assert_predicate AccountPolicy.new(@owner_user, @account), :show?
  end

  test "account create available by logged in users" do
    assert_not_predicate AccountPolicy.new(nil, @account), :create?

    assert_predicate AccountPolicy.new(@user, @account), :create?
    assert_predicate AccountPolicy.new(@admin_user, @account), :create?
    assert_predicate AccountPolicy.new(@owner_user, @account), :create?
  end

  test "account new available by logged in users" do
    assert_not_predicate AccountPolicy.new(nil, @account), :new?

    assert_predicate AccountPolicy.new(@user, @account), :new?
    assert_predicate AccountPolicy.new(@admin_user, @account), :new?
    assert_predicate AccountPolicy.new(@owner_user, @account), :new?
  end

  test "account edit available by admins" do
    assert_not_predicate AccountPolicy.new(nil, @account), :edit?
    assert_not_predicate AccountPolicy.new(@user, @account), :edit?

    assert_predicate AccountPolicy.new(@admin_user, @account), :edit?
    assert_predicate AccountPolicy.new(@owner_user, @account), :edit?
  end

  test "account update available by admins" do
    assert_not_predicate AccountPolicy.new(nil, @account), :update?
    assert_not_predicate AccountPolicy.new(@user, @account), :update?

    assert_predicate AccountPolicy.new(@admin_user, @account), :update?
    assert_predicate AccountPolicy.new(@owner_user, @account), :update?
  end

  test "account destroy only available to owner" do
    assert_not_predicate AccountPolicy.new(nil, @account), :destroy?
    assert_not_predicate AccountPolicy.new(@user, @account), :destroy?

    # Create another admin who is not the owner
    other_identity = Identity.create!(
      email_address: "admin2@feedbackbin.com",
      password: "password123456"
    )
    other_admin = User.create!(
      name: "Admin Two",
      identity: other_identity,
      account: @account,
      role: :admin
    )

    assert_not_predicate AccountPolicy.new(other_admin, @account), :destroy?

    # Only the owner (user with owner role) can destroy
    owner = users(:shane)

    assert_predicate AccountPolicy.new(owner, @account), :destroy?
  end
end
