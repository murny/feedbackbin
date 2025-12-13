# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "valid user" do
    assert_predicate @user, :valid?
  end

  test "invalid without name" do
    @user.name = nil

    assert_not @user.valid?
    assert_equal("can't be blank", @user.errors[:name].first)
  end

  test "name gets stripped when saved" do
    @user.update!(name: " John      Doe      ")

    assert_equal "John Doe", @user.name
  end

  test "delegates email_address to identity" do
    assert_equal @user.identity.email_address, @user.email_address
  end

  test "invalid when bio is too large" do
    @user.bio = "abc" * 100

    assert_not @user.valid?
    assert_equal("is too long (maximum is 255 characters)", @user.errors[:bio].first)
  end

  test "should accept avatars of valid file formats" do
    @user.avatar.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    assert_predicate @user, :valid?
  end

  test "destroying a membership revokes sessions scoped to that account" do
    assert_difference("Session.count", -1) do
      @user.destroy
    end
  end

  test "can deactivate a regular user" do
    @user.deactivate

    @user.reload

    assert_predicate @user, :deactivated?
    assert_not @user.active
  end

  test "cannot deactivate account owner" do
    owner = users(:shane)

    assert_not owner.deactivate
    assert owner.reload.active
    assert_equal "account owner cannot be deactivated", owner.errors[:active].first
  end

  test "deactivate clears all user sessions" do
    # Create additional session
    @user.identity.sessions.create!(user_agent: "test", ip_address: "127.0.0.1", current_account: @user.account)

    assert_equal 2, @user.sessions.count

    @user.deactivate

    assert_equal 0, @user.sessions.count
  end

  test "active scope returns only active users" do
    deactivated_user = users(:two)
    deactivated_user.deactivate

    active_users = User.active

    assert_includes active_users, @user
    assert_not_includes active_users, deactivated_user
  end

  test "deactivated scope returns only deactivated users" do
    deactivated_user = users(:two)
    deactivated_user.deactivate

    deactivated_users = User.deactivated

    assert_includes deactivated_users, deactivated_user
    assert_not_includes deactivated_users, @user
  end
end
