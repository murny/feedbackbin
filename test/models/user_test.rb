# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:shane)
  end
  test "invalid if using very long password" do
    @user.update(password: "secret" * 15)

    assert_not @user.valid?
    assert_equal "is too long", @user.errors[:password].first
  end

  test "avatar is present?" do
    avatar = @user.avatar

    assert_predicate @user, :valid?
    assert_predicate avatar, :attached?

    assert_equal 31648, avatar.byte_size
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
end
