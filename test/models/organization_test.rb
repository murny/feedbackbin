# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:feedbackbin)
  end

  test "valid organization" do
    assert_predicate @organization, :valid?
  end

  test "invalid without name" do
    @organization.name = nil

    assert_not_predicate @organization, :valid?
    assert_equal "can't be blank", @organization.errors[:name].first
  end

  test "should accept logo of valid file formats" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    assert_predicate @organization, :valid?
  end

  test "should reject logo of invalid file formats" do
    @organization.logo.attach(io: file_fixture("test.txt").open, filename: "test.txt", content_type: "text/plain")

    assert_not @organization.valid?
    assert_equal("image format not supported", @organization.errors[:logo].first)
  end

  test "should enforce a maximum logo file size" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")
    @organization.logo.blob.stub :byte_size, 3.megabytes do
      assert_not @organization.valid?
      assert_equal("image over 2 MB", @organization.errors[:logo].first)
    end
  end

  test "organization must have a default status" do
    @organization.default_post_status = nil

    assert_not @organization.valid?
    assert_equal "must exist", @organization.errors[:default_post_status].first
  end

  # Owner tests
  test "organization requires an owner" do
    @organization.owner = nil

    assert_not @organization.valid?
    assert_equal "must exist", @organization.errors[:owner].first
  end

  test "owner must be an administrator" do
    member = users(:one)
    @organization.owner = member

    assert_not @organization.valid?
    assert_includes @organization.errors[:owner], "must be an administrator"
  end

  test "owner can be an administrator" do
    admin = users(:shane)
    @organization.owner = admin

    assert_predicate @organization, :valid?
  end

  test "owned_by? returns true for owner" do
    assert @organization.owned_by?(@organization.owner)
  end

  test "owned_by? returns false for non-owner" do
    other_user = users(:one)

    assert_not @organization.owned_by?(other_user)
  end
end
