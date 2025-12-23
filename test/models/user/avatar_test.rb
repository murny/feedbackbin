# frozen_string_literal: true

require "test_helper"

class User::AvatarTest < ActiveSupport::TestCase
  setup do
    @user = users(:shane)
  end

  test "avatar_thumbnail returns variant for variable images" do
    @user.avatar.attach(io: File.open(file_fixture("moon.jpg")), filename: "moon.jpg", content_type: "image/jpeg")

    assert_predicate @user.avatar, :variable?
    assert_equal @user.avatar.variant(:thumb).blob, @user.avatar_thumbnail.blob
  end

  test "avatar_thumbnail returns original blob for non-variable images" do
    @user.avatar.attach(io: File.open(file_fixture("avatar.svg")), filename: "avatar.svg", content_type: "image/svg+xml")

    assert_not @user.avatar.variable?
    assert_equal @user.avatar.blob, @user.avatar_thumbnail.blob
  end

  test "allows valid image content types" do
    @user.avatar.attach(io: File.open(file_fixture("moon.jpg")), filename: "test.jpg", content_type: "image/jpeg")

    assert_predicate @user, :valid?
  end

  test "rejects SVG uploads" do
    @user.avatar.attach(io: File.open(file_fixture("avatar.svg")), filename: "avatar.svg")

    assert_not @user.valid?
    assert_equal("file type is not supported", @user.errors[:avatar].first)
  end

  test "thumb variant is processed immediately on attachment" do
    @user.avatar.attach(io: File.open(file_fixture("avatar.png")), filename: "avatar.png", content_type: "image/png")

    assert_predicate @user.avatar.variant(:thumb), :processed?
  end

  test "rejects avatars exceeding maximum file size" do
    @user.avatar.attach(io: File.open(file_fixture("racecar.jpeg")), filename: "racecar.jpeg", content_type: "image/jpeg")

    @user.avatar.blob.stubs(:byte_size).returns(3.megabytes)

    assert_not @user.valid?
    assert_equal("exceeds maximum size of 2 MB", @user.errors[:avatar].first)
  end
end
