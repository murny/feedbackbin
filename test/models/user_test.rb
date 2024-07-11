require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user does not prevent very long passwords" do
    users(:shane).update(password: "secret" * 50)
    assert users(:shane).valid?
  end
end
