# frozen_string_literal: true

require "test_helper"

class IdentityTest < ActiveSupport::TestCase
  def setup
    @identity = identities(:jane)
  end

  test "valid identity" do
    assert_predicate @identity, :valid?
  end

  test "invalid without email address" do
    @identity.email_address = nil

    assert_not @identity.valid?
    assert_equal("can't be blank", @identity.errors[:email_address].first)
  end

  test "invalid if email address taken already" do
    @identity.email_address = "shane.murnaghan@feedbackbin.com"

    assert_not @identity.valid?
    assert_equal("has already been taken", @identity.errors[:email_address].first)
  end

  test "invalid if email address not a valid email address" do
    @identity.email_address = "bad_email_address_here"

    assert_not @identity.valid?
    assert_equal("is invalid", @identity.errors[:email_address].first)
  end

  test "email address gets downcased and stripped when saved" do
    @identity.update!(email_address: " John.Doe@example.com ")

    assert_equal "john.doe@example.com", @identity.email_address
  end

  test "invalid if using very long password" do
    @identity.password = "secret" * 15

    assert_not @identity.valid?
    assert_equal "is too long (maximum is 72 characters)", @identity.errors[:password].first
  end

  test "invalid if password is too short" do
    @identity.password = "short"

    assert_not @identity.valid?
    assert_equal("is too short (minimum is 10 characters)", @identity.errors[:password].first)
  end

  test "sessions are destroyed when identity is destroyed" do
    assert_difference("Session.count", -1) do
      @identity.destroy
    end
  end
end
