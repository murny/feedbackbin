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
    assert_equal("file type is not supported", @organization.errors[:logo].first)
  end

  test "should enforce a maximum logo file size" do
    @organization.logo.attach(io: file_fixture("racecar.jpeg").open, filename: "racecar.jpeg", content_type: "image/jpeg")
    @organization.logo.blob.stub :byte_size, 3.megabytes do
      assert_not @organization.valid?
      assert_equal("exceeds maximum size of 2 MB", @organization.errors[:logo].first)
    end
  end

  test "organization must have a default status" do
    @organization.default_post_status = nil

    assert_not @organization.valid?
    assert_equal "must exist", @organization.errors[:default_post_status].first
  end


  test "owned_by? returns true for user with owner role" do
    owner = users(:shane)

    assert @organization.owned_by?(owner)
  end

  test "owned_by? returns false for non-owner" do
    other_user = users(:one)

    assert_not @organization.owned_by?(other_user)
  end

  # Branding tests
  test "show_company_name defaults to true" do
    org = Organization.new(name: "Test Org", default_post_status: post_statuses(:open))

    assert org.show_company_name
  end

  test "show_company_name can be set to false" do
    @organization.show_company_name = false

    assert_not @organization.show_company_name
  end

  test "validates logo_link as valid URL" do
    @organization.logo_link = "https://example.com"

    assert_predicate @organization, :valid?

    @organization.logo_link = "/posts"

    assert_not @organization.valid?

    @organization.logo_link = "not-a-url"

    assert_not @organization.valid?

    @organization.logo_link = "javascript:alert('xss')"

    assert_not @organization.valid?
  end

  test "favicon can be attached" do
    @organization.favicon.attach(io: file_fixture("random.jpeg").open, filename: "favicon.jpg", content_type: "image/jpeg")

    assert_predicate @organization.favicon, :attached?
    assert_predicate @organization, :valid?
  end

  test "favicon enforces file size limit" do
    @organization.favicon.attach(io: file_fixture("racecar.jpeg").open, filename: "favicon.jpg", content_type: "image/jpeg")

    @organization.favicon.blob.stub :byte_size, 2.megabytes do
      assert_not @organization.valid?
      assert_includes @organization.errors[:favicon], "exceeds maximum size of 500 KB"
    end
  end

  test "og_image can be attached" do
    @organization.og_image.attach(io: file_fixture("racecar.jpeg").open, filename: "og-image.jpg", content_type: "image/jpeg")

    assert_predicate @organization.og_image, :attached?
  end
end
