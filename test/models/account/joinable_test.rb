require "test_helper"

class Account::JoinableTest < ActiveSupport::TestCase
  test "new accounts get a joinable code" do
    Account.destroy_all
    account = Account.create!(name: "Chat")
    assert_match /\w{4}-\w{4}-\w{4}/, account.join_code
  end

  test "accounts can reset join code" do
    assert_changes -> { accounts(:feedbackbin).reload.join_code } do
      accounts(:feedbackbin).reset_join_code
    end
  end
end
