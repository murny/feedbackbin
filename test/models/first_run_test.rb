# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Account.destroy_all
    AccountUser.destroy_all
    Board.destroy_all
    User.destroy_all
  end

  test "creating makes first user an administrator and sets up a new board and account" do
    assert_difference "Board.count" do
      assert_difference "User.count" do
        assert_difference "Account.count" do
          assert_difference "AccountUser.count" do
            account = FirstRun.create!({username: "owner_example", email_address: "owner@example.com", password: "secret123456"})

            assert_predicate account.account_users.first, :administrator?
            assert_equal account.account_users.first.user, account.owner
            assert_equal "owner@example.com", account.owner.email_address
          end
        end
      end
    end
  end
end
