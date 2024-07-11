require "test_helper"

class User::RoleTest < ActiveSupport::TestCase
  test "creating users makes them members by default" do
    assert User.create!(name: "User", email_address: "user@example.com", password: "secret123456").member?
  end

  test "can_administer?" do
    assert User.new(role: :administrator).can_administer?

    assert_not User.new(role: :member).can_administer?
    assert_not User.new.can_administer?
  end
end
