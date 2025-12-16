# frozen_string_literal: true

require "test_helper"

class Account
  class DomainableTest < ActiveSupport::TestCase
    setup do
      @account = accounts(:feedbackbin)
      @original_multi_tenant = Rails.application.config.multi_tenant
    end

    teardown do
      Rails.application.config.multi_tenant = @original_multi_tenant
    end

    test "subdomain is optional in single-tenant mode" do
      Rails.application.config.multi_tenant = false
      @account.subdomain = nil

      assert_predicate @account, :valid?

      @account.subdomain = ""

      assert_predicate @account, :valid?
    end

    test "subdomain is required in multi-tenant mode" do
      Rails.application.config.multi_tenant = true
      @account.subdomain = nil

      assert_not @account.valid?
      assert_equal "can't be blank", @account.errors[:subdomain].first
    end

    test "validates uniqueness of subdomain when present" do
      original = Account.create!(
        name: "test",
        subdomain: "test"
      )
      account = original.dup

      assert_not account.valid?
      assert_equal "has already been taken", account.errors[:subdomain].first
    end

    test "validates against reserved subdomains" do
      @account.subdomain = "app"

      assert_not @account.valid?
      assert_equal "app is reserved", @account.errors[:subdomain].first
    end

    test "subdomain format must start with alphanumeric char" do
      @account.subdomain = "-abcd"

      assert_not @account.valid?
      assert_equal "must be at least 2 characters and alphanumeric", @account.errors[:subdomain].first
    end

    test "subdomain format must end with alphanumeric char" do
      @account.subdomain = "abcd-"

      assert_not @account.valid?
      assert_equal "must be at least 2 characters and alphanumeric", @account.errors[:subdomain].first
    end

    test "must be at least two characters" do
      @account.subdomain = "a"

      assert_not @account.valid?
      assert_equal "must be at least 2 characters and alphanumeric", @account.errors[:subdomain].first
    end

    test "can use a mixture of alphanumeric, hyphen, and underscore" do
      @account.subdomain = "abc"

      assert_predicate @account, :valid?

      @account.subdomain = "123"

      assert_predicate @account, :valid?

      @account.subdomain = "a-9"

      assert_predicate @account, :valid?

      @account.subdomain = "1_b"

      assert_predicate @account, :valid?
    end

    test "invalid if subdomain shorter than 3 characters" do
      @account.subdomain = "ab"

      assert_not @account.valid?
      assert_equal "is too short (minimum is 3 characters)", @account.errors[:subdomain].first
    end

    test "invalid if subdomain longer than 50 characters" do
      @account.subdomain = "a" * 51

      assert_not @account.valid?
      assert_equal "is too long (maximum is 50 characters)", @account.errors[:subdomain].first
    end

    test "subdomain gets downcased and stripped when saved" do
      @account.update!(subdomain: "  AbC-_Def  ")

      assert_equal "abc-_def", @account.subdomain
    end
  end
end
