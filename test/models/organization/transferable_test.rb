# frozen_string_literal: true

require "test_helper"

class Organization::TransferableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @organization = organizations(:company)
  end

  test "can_transfer? true for owner" do
    assert @organization.can_transfer?(@organization.owner)
  end

  test "can_transfer? false for non-owner" do
    assert_not @organization.can_transfer?(users(:shane))
  end

  test "can_transfer? false for single user" do
    @organization.users = [@organization.owner]

    assert_not @organization.can_transfer?(@organization.owner)
  end

  test "transfer ownership to a new owner" do
    new_owner = users(:shane)

    assert @organization.transfer_ownership(new_owner.id)
    assert_equal new_owner, @organization.reload.owner
  end

  test "transfer ownership fails transferring to a user outside the organization" do
    owner = @organization.owner

    assert_not @organization.transfer_ownership(users(:invited).id)
    assert_equal owner, @organization.reload.owner
  end
end
