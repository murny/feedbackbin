# frozen_string_literal: true

require "test_helper"

class AccountTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:feedbackbin)
  end

  test "valid account" do
    assert_predicate @account, :valid?
  end

  test "invalid without name" do
    @account.name = nil

    assert_not_predicate @account, :valid?
    assert_equal "can't be blank", @account.errors[:name].first
  end

  test "should accept logo of valid file formats" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")

    assert_predicate @account, :valid?
  end

  test "should reject logo of invalid file formats" do
    @account.logo.attach(io: file_fixture("test.txt").open, filename: "test.txt", content_type: "text/plain")

    assert_not @account.valid?
    assert_equal("file type is not supported", @account.errors[:logo].first)
  end

  test "should enforce a maximum logo file size" do
    @account.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")
    @account.logo.blob.stubs(:byte_size).returns(3.megabytes)

    assert_not @account.valid?
    assert_equal("exceeds maximum size of 2 MB", @account.errors[:logo].first)
  end

  test "owned_by? returns true for user with owner role" do
    owner = users(:shane)

    assert @account.owned_by?(owner)
  end

  test "owned_by? returns false for non-owner" do
    other_user = users(:jane)

    assert_not @account.owned_by?(other_user)
  end

  # Branding tests
  test "show_company_name defaults to true" do
    account = Account.new(name: "Test Org")

    assert account.show_company_name
  end

  test "show_company_name can be set to false" do
    @account.show_company_name = false

    assert_not @account.show_company_name
  end

  test "validates logo_link as valid URL" do
    @account.logo_link = "https://example.com"

    assert_predicate @account, :valid?

    @account.logo_link = "/about"

    assert_not @account.valid?

    @account.logo_link = "not-a-url"

    assert_not @account.valid?

    @account.logo_link = "javascript:alert('xss')"

    assert_not @account.valid?
  end

  test "favicon can be attached" do
    @account.favicon.attach(io: file_fixture("random.jpeg").open, filename: "favicon.jpg", content_type: "image/jpeg")

    assert_predicate @account.favicon, :attached?
    assert_predicate @account, :valid?
  end

  test "favicon enforces file size limit" do
    @account.favicon.attach(io: file_fixture("racecar.jpeg").open, filename: "favicon.jpg", content_type: "image/jpeg")

    @account.favicon.blob.stubs(:byte_size).returns(2.megabytes)

    assert_not @account.valid?
    assert_includes @account.errors[:favicon], "exceeds maximum size of 500 KB"
  end

  test "og_image can be attached" do
    @account.og_image.attach(io: file_fixture("racecar.jpeg").open, filename: "og-image.jpg", content_type: "image/jpeg")

    assert_predicate @account.og_image, :attached?
  end
end
