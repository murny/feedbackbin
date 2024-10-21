# frozen_string_literal: true

require "test_helper"

class Account::TransferableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @account = accounts(:company)
  end

  test "can_transfer? true for owner" do
    assert @account.can_transfer?(@account.owner)
  end

  test "can_transfer? false for non-owner" do
    assert_not @account.can_transfer?(users(:shane))
  end

  test "can_transfer? false for single user" do
    @account.users = [@account.owner]

    assert_not @account.can_transfer?(@account.owner)
  end

  test "transfer ownership to a new owner" do
    new_owner = users(:shane)

    assert @account.transfer_ownership(new_owner.id)
    assert_equal new_owner, @account.reload.owner
  end

  test "transfer ownership fails transferring to a user outside the account" do
    owner = @account.owner

    assert_not @account.transfer_ownership(users(:invited).id)
    assert_equal owner, @account.reload.owner
  end
end
