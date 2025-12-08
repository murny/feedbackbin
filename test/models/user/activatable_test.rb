# frozen_string_literal: true

require "test_helper"

class User::ActivatableTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @organization = organizations(:feedbackbin)
    Current.organization = @organization
  end

  test "active scope returns only active users" do
    active_user = @user
    active_user.update!(active: true)

    inactive_user = users(:two)
    inactive_user.deactivate

    active_users = User.active

    assert_includes active_users, active_user
    assert_not_includes active_users, inactive_user
  end

  test "deactivated scope returns only deactivated users" do
    active_user = @user
    active_user.update!(active: true)

    inactive_user = users(:two)
    inactive_user.deactivate

    deactivated_users = User.deactivated

    assert_not_includes deactivated_users, active_user
    assert_includes deactivated_users, inactive_user
  end

  test "deactivate sets user as inactive" do
    @user.update!(active: true)

    result = @user.deactivate

    assert result
    assert_not @user.active?
    assert_not @user.reload.active
  end

  test "deactivate clears user sessions" do
    @user.update!(active: true)
    # Create a session for this specific user
    session = Session.create!(user: @user, ip_address: "127.0.0.1", user_agent: "Test")

    @user.deactivate

    assert_not Session.exists?(session.id)
  end

  test "deactivate returns false on validation failure" do
    # Make the user an organization owner (can't be deactivated)
    @user.update!(role: :administrator)
    org = Organization.create!(
      name: "Test Org",
      subdomain: "testorg#{rand(10000)}",
      default_post_status: post_statuses(:open),
      owner: @user
    )

    # Reload user to get the owned_organization association
    @user.reload

    result = @user.deactivate

    assert_not result
    assert @user.reload.active?
  end

  test "deactivated? returns true when user is inactive" do
    @user.update!(active: false)

    assert_predicate @user, :deactivated?
  end

  test "deactivated? returns false when user is active" do
    @user.update!(active: true)

    assert_not @user.deactivated?
  end

  test "validates organization owner cannot be deactivated" do
    @user.update!(role: :administrator, active: true)
    org = Organization.create!(
      name: "Test Org 2",
      subdomain: "testorg2#{rand(10000)}",
      default_post_status: post_statuses(:open),
      owner: @user
    )

    # Reload user to get the owned_organization association
    @user.reload
    @user.active = false

    assert_not @user.valid?
    # Check that there are errors on the active attribute
    assert @user.errors[:active].any?
  end

  test "allows deactivating regular users" do
    @user.update!(active: true)
    @user.active = false

    assert_predicate @user, :valid?
  end
end
