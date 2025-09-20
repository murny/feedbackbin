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

  test "invalid without owner" do
    @organization.owner = nil

    assert_not_predicate @organization, :valid?
    assert_equal "must exist", @organization.errors[:owner].first
  end

  test "owner?" do
    assert @organization.owner?(users(:shane))
    assert_not @organization.owner?(users(:one))
    assert_not @organization.owner?(nil)
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
end
