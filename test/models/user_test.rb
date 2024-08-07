# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:shane)
  end
  test "invalid if using very long password" do
    @user.update(password: "secret" * 15)

    assert_not @user.valid?
    assert_equal "is too long", @user.errors[:password].first
  end
end
