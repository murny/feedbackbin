# frozen_string_literal: true

require "test_helper"

class FirstRunTest < ActiveSupport::TestCase
  setup do
    Account.destroy_all
  end

  test "creating makes first user an owner and sets up a new board and account" do
    assert_difference [ "Board.count", "User.count", "Account.count" ] do
      first_run = FirstRun.new(
        name: "Owner Example",
        email_address: "owner@example.com",
        password: "secret123456",
        account_name: "Test Account",
        board_name: "Test Board",
        board_color: "#3b82f6"
      ).save!

      assert_predicate first_run.user, :owner?
      assert_equal "Test Account", first_run.account.name
      assert_equal "Test Board", first_run.board.name
      assert_equal "Owner Example", first_run.user.name
      assert_equal "owner@example.com", first_run.user.email_address
    end
  end

  test "validates required fields" do
    first_run = FirstRun.new

    assert_not first_run.valid?
    assert_equal "can't be blank", first_run.errors[:name].first
    assert_equal "can't be blank", first_run.errors[:email_address].first
    assert_equal "can't be blank", first_run.errors[:password].first
    assert_equal "can't be blank", first_run.errors[:account_name].first
    assert_equal "can't be blank", first_run.errors[:board_name].first
    assert_equal "can't be blank", first_run.errors[:board_color].first
  end
end
