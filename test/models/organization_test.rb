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

  # Module management tests
  test "at least one module must be enabled" do
    @organization.posts_enabled = false
    @organization.roadmap_enabled = false
    @organization.changelog_enabled = false

    assert_not @organization.valid?
    assert_includes @organization.errors[:base], "At least one module must be enabled"
  end

  test "can disable individual modules if others remain" do
    @organization.roadmap_enabled = false

    assert @organization.valid?
    assert @organization.posts_enabled?
    assert_not @organization.roadmap_enabled?
    assert @organization.changelog_enabled?
  end

  test "root_path_module must be an enabled module" do
    @organization.roadmap_enabled = false
    @organization.root_path_module = :roadmap

    assert_not @organization.valid?
    assert_includes @organization.errors[:root_path_module], "The default landing page must be an enabled module"
  end

  test "enabled_modules returns only enabled modules" do
    @organization.roadmap_enabled = false

    assert_equal [ :posts, :changelog ], @organization.enabled_modules
  end

  test "module_enabled? checks specific module" do
    @organization.roadmap_enabled = false

    assert @organization.module_enabled?(:posts)
    assert_not @organization.module_enabled?(:roadmap)
    assert @organization.module_enabled?(:changelog)
  end

  test "root_path_url returns correct path for posts" do
    @organization.root_path_module = :posts

    assert_equal "/posts", @organization.root_path_url
  end

  test "root_path_url returns correct path for roadmap" do
    @organization.root_path_module = :roadmap

    assert_equal "/roadmap", @organization.root_path_url
  end

  test "root_path_url returns correct path for changelog" do
    @organization.root_path_module = :changelog

    assert_equal "/changelogs", @organization.root_path_url
  end
end
