# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:company)
  end

  test "valid account" do
    assert_predicate @account, :valid?
  end

  test "invalid without name" do
    @account.name = nil

    assert_not_predicate @account, :valid?
    assert_equal "can't be blank", @account.errors[:name].first
  end

  test "invalid without owner" do
    @account.owner = nil

    assert_not_predicate @account, :valid?
    assert_equal "must exist", @account.errors[:owner].first
  end

  test "owner?" do
    assert @account.owner?(users(:one))
    assert_not @account.owner?(users(:shane))
  end

  test "should accept logo of valid file formats" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    assert_predicate @account, :valid?
  end

  test "should reject logo of invalid file formats" do
    @account.logo.attach(io: file_fixture("test.txt").open, filename: "test.txt", content_type: "text/plain")

    assert_not @account.valid?
    assert_equal("image format not supported", @account.errors[:logo].first)
  end

  test "should enforce a maximum logo file size" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")
    @account.logo.blob.stub :byte_size, 3.megabytes do
      assert_not @account.valid?
      assert_equal("image over 2 MB", @account.errors[:logo].first)
    end
  end
end
