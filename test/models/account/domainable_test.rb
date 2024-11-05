# frozen_string_literal: true

require "test_helper"

class Account::DomainableTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:company)
  end

  test "validates uniqueness of domain" do
    account = @account.dup

    assert_not account.valid?
    assert_equal "has already been taken", account.errors[:domain].first
  end

  test "can have multiple accounts with no domain and/or subdomain" do
    user = users(:one)

    account_one = Account.create!(owner: user, name: "test")
    account_two = Account.create!(owner: user, name: "test2")

    assert_predicate account_one, :valid?
    assert_predicate account_two, :valid?
  end

  test "validates uniqueness of subdomain" do
    original = Account.create!(owner: users(:one), name: "test", subdomain: "test")
    account = original.dup

    assert_not account.valid?
    assert_equal "has already been taken", account.errors[:subdomain].first
  end

  test "validates against reserved domains" do
    @account.domain = "feedbackbin.com"

    assert_not @account.valid?
    assert_equal "feedbackbin.com is reserved", @account.errors[:domain].first
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
    @account.subdomain = "ab"

    assert_predicate @account, :valid?

    @account.subdomain = "12"

    assert_predicate @account, :valid?

    @account.subdomain = "a-9"

    assert_predicate @account, :valid?

    @account.subdomain = "1_b"

    assert_predicate @account, :valid?
  end
end
