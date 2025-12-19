# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:jane)
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

  test "invalid when bio is too large" do
    @user.bio = "abc" * 100

    assert_not @user.valid?
    assert_equal("is too long (maximum is 255 characters)", @user.errors[:bio].first)
  end

  test "should accept avatars of valid file formats" do
    @user.avatar.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    assert_predicate @user, :valid?
  end

  test "can deactivate a regular user" do
    assert_predicate @user, :active?

    @user.deactivate

    assert_not_predicate @user.reload, :active?
  end

  test "cannot deactivate account owner" do
    owner = users(:shane)

    error = assert_raises ActiveRecord::RecordInvalid do
      owner.deactivate
    end

    assert_equal "Validation failed: Active account owner cannot be deactivated", error.message
    assert_predicate owner.reload, :active?
  end

  test "active scope returns only active users" do
    deactivated_user = users(:john)
    deactivated_user.deactivate

    active_users = User.active

    assert_includes active_users, @user
    assert_not_includes active_users, deactivated_user
  end

  test "deactivated scope returns only deactivated users" do
    deactivated_user = users(:john)
    deactivated_user.deactivate

    deactivated_users = User.deactivated

    assert_includes deactivated_users, deactivated_user
    assert_not_includes deactivated_users, @user
  end
end
