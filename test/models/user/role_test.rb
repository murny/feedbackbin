# frozen_string_literal: true

require "test_helper"

class User::RoleTest < ActiveSupport::TestCase
  test "creating users makes them members by default" do
    assert_predicate User.create!(username: "test_user", name: "User", email_address: "user@example.com", password: "secret123456"), :member?
  end

  test "can_administer?" do
    assert_predicate User.new(role: :administrator), :can_administer?

    assert_not User.new(role: :member).can_administer?
    assert_not User.new.can_administer?
  end

  test "Roles must be a valid role" do
    @user = users(:one)
    @user.role = :super_admin

    assert_not @user.valid?
    assert_equal("is not included in the list", @user.errors[:role].first)
  end
end
