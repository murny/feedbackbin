# frozen_string_literal: true

require "test_helper"

class Organization
  class DomainableTest < ActiveSupport::TestCase
    setup do
      @organization = organizations(:feedbackbin)
    end

    test "validates presence of subdomain" do
      @organization.subdomain = nil

      assert_not @organization.valid?
      assert_equal "can't be blank", @organization.errors[:subdomain].first
    end

    test "validates uniqueness of subdomain" do
      original = Organization.create!(
        name: "test",
        subdomain: "test",
        default_post_status: post_statuses(:open),
        owner: users(:shane)
      )
      organization = original.dup

      assert_not organization.valid?
      assert_equal "has already been taken", organization.errors[:subdomain].first
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
      @organization.subdomain = "abc"

      assert_predicate @organization, :valid?

      @organization.subdomain = "123"

      assert_predicate @organization, :valid?

      @organization.subdomain = "a-9"

      assert_predicate @organization, :valid?

      @organization.subdomain = "1_b"

      assert_predicate @organization, :valid?
    end

    test "invalid if subdomain shorter than 3 characters" do
      @organization.subdomain = "ab"

      assert_not @organization.valid?
      assert_equal "is too short (minimum is 3 characters)", @organization.errors[:subdomain].first
    end

    test "invalid if subdomain longer than 50 characters" do
      @organization.subdomain = "a" * 51

      assert_not @organization.valid?
      assert_equal "is too long (maximum is 50 characters)", @organization.errors[:subdomain].first
    end

    test "subdomain gets downcased and stripped when saved" do
      @organization.update!(subdomain: "  AbC-_Def  ")

      assert_equal "abc-_def", @organization.subdomain
    end
  end
end
