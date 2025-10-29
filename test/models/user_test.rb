# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "valid user" do
    assert_predicate @user, :valid?
  end

  test "invalid without username" do
    @user.username = nil

    assert_not @user.valid?
    assert_equal(I18n.t("errors.messages.blank"), @user.errors[:username].first)
  end

  test "invalid if username contains non alphanumeric characters" do
    @user.username = "user@name"

    assert_not @user.valid?
    assert_equal("can only contain letters, numbers, and underscores", @user.errors[:username].first)
  end

  test "invalid if username longer then 20 characters" do
    @user.username = "coolusername1234567890"

    assert_not @user.valid?
    assert_equal("is too long (maximum is 20 characters)", @user.errors[:username].first)
  end

  test "invalid if username shorter then 3 characters" do
    @user.username = "ab"

    assert_not @user.valid?
    assert_equal("is too short (minimum is 3 characters)", @user.errors[:username].first)
  end

  test "invalid if username taken already" do
    @user.username = "Murny"

    assert_not @user.valid?
    assert_equal("has already been taken", @user.errors[:username].first)
  end

  test "username gets stripped when saved" do
    @user.update!(username: " ExAmPlE_UsErNaMe ")

    assert_equal "ExAmPlE_UsErNaMe", @user.username
  end

  test "name gets stripped when saved" do
    @user.update!(name: " John      Doe      ")

    assert_equal "John Doe", @user.name
  end

  test "invalid without email address" do
    @user.email_address = nil

    assert_not @user.valid?
    assert_equal(I18n.t("errors.messages.blank"), @user.errors[:email_address].first)
  end

  test "invalid if email address taken already" do
    @user.email_address = "shane.murnaghan@feedbackbin.com"

    assert_not @user.valid?
    assert_equal("has already been taken", @user.errors[:email_address].first)
  end

  test "invalid if email address not a valid email address" do
    @user.email_address = "bad_email_address_here"

    assert_not @user.valid?
    assert_equal("is invalid", @user.errors[:email_address].first)
  end

  test "email address gets downcased and stripped when saved" do
    @user.update!(email_address: " John.Doe@example.com ")

    assert_equal "john.doe@example.com", @user.email_address
  end

  test "invalid if using very long password" do
    @user.password = "secret" * 15

    assert_not @user.valid?
    assert_equal "is too long", @user.errors[:password].first
  end

  test "invalid if password is too short" do
    @user.password = "short"

    assert_not @user.valid?
    assert_equal("is too short (minimum is 10 characters)", @user.errors[:password].first)
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

  test "should reject avatars of invalid file formats" do
    @user.avatar.attach(io: file_fixture("test.txt").open, filename: "test.txt", content_type: "text/plain")

    assert_not @user.valid?
    assert_equal("image format not supported", @user.errors[:avatar].first)
  end

  test "should enforce a maximum avatar file size" do
    @user.avatar.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")
    @user.avatar.blob.stub :byte_size, 3.megabytes do
      assert_not @user.valid?
      assert_equal("image over 2 MB", @user.errors[:avatar].first)
    end
  end

  test "anonymizes the filename of the avatar" do
    @user.avatar.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    # it anonymizes the filename of the avatar
    assert_equal("avatar.jpeg", @user.avatar.filename.to_s)
  end

  test "sessions are destroyed when user is destroyed" do
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

  test "cannot deactivate organization owner" do
    owner = users(:shane)

    assert_not owner.deactivate
    assert owner.reload.active
    assert_equal "organization owner cannot be deactivated", owner.errors[:active].first
  end

  test "deactivate clears all user sessions" do
    # Create additional session
    @user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")

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
