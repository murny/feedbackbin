# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Account.destroy_all
    Board.destroy_all
    User.destroy_all
  end

  test "creating makes first user an administrator and sets up a new board and account" do
    assert_difference "Board.count" do
      assert_difference "User.count" do
        user = FirstRun.create!({username: "user_example", email_address: "user@example.com", password: "secret123456"})

        assert_predicate user, :administrator?
      end
    end
  end
end
