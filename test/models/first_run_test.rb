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
    assert_difference -> { Board.count }, 1 do
      assert_difference -> { User.count }, 1 do
        assert_difference -> { Account.count }, 1 do
          assert_difference -> { AccountUser.count }, 1 do
            account = FirstRun.create!({username: "user_example", email_address: "user@example.com", password: "secret123456"})

            assert_equal "user_example", account.owner.username
          end
        end
      end
    end
  end
end
