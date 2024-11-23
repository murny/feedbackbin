# frozen_string_literal: true

require "test_helper"

class Organization::DomainableTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:company)
  end

  test "validates uniqueness of domain" do
    organization = @organization.dup

    assert_not organization.valid?
    assert_equal "has already been taken", organization.errors[:domain].first
  end

  test "can have multiple organizations with no domain and/or subdomain" do
    user = users(:one)

    organization_one = Organization.create!(owner: user, name: "test")
    organization_two = Organization.create!(owner: user, name: "test2")

    assert_predicate organization_one, :valid?
    assert_predicate organization_two, :valid?
  end

  test "validates uniqueness of subdomain" do
    original = Organization.create!(owner: users(:one), name: "test", subdomain: "test")
    organization = original.dup

    assert_not organization.valid?
    assert_equal "has already been taken", organization.errors[:subdomain].first
  end

  test "validates against reserved domains" do
    @organization.domain = "feedbackbin.com"

    assert_not @organization.valid?
    assert_equal "feedbackbin.com is reserved", @organization.errors[:domain].first
  end

  test "validates against reserved subdomains" do
    @organization.subdomain = "app"

    assert_not @organization.valid?
    assert_equal "app is reserved", @organization.errors[:subdomain].first
  end

  test "subdomain format must start with alphanumeric char" do
    @organization.subdomain = "-abcd"

    assert_not @organization.valid?
    assert_equal "must be at least 2 characters and alphanumeric", @organization.errors[:subdomain].first
  end

  test "subdomain format must end with alphanumeric char" do
    @organization.subdomain = "abcd-"

    assert_not @organization.valid?
    assert_equal "must be at least 2 characters and alphanumeric", @organization.errors[:subdomain].first
  end

  test "must be at least two characters" do
    @organization.subdomain = "a"

    assert_not @organization.valid?
    assert_equal "must be at least 2 characters and alphanumeric", @organization.errors[:subdomain].first
  end

  test "can use a mixture of alphanumeric, hyphen, and underscore" do
    @organization.subdomain = "ab"

    assert_predicate @organization, :valid?

    @organization.subdomain = "12"

    assert_predicate @organization, :valid?

    @organization.subdomain = "a-9"

    assert_predicate @organization, :valid?

    @organization.subdomain = "1_b"

    assert_predicate @organization, :valid?
  end
end
