# frozen_string_literal: true

require "test_helper"

class SignupTest < ActiveSupport::TestCase
  setup do
    Identity.delete_all
    Account.delete_all
  end

  test "creating makes first user an owner and sets up template data" do
    assert_difference [ "Board.count", "Account.count", "Identity.count" ] do
      assert_difference "User.count", 2 do  # system user + owner
        assert_difference "Idea.count", 3 do  # template ideas
          signup = Signup.new(
            name: "Owner Example",
            email_address: "owner@example.com",
            password: "secret123456",
            account_name: "Test Account"
          ).save!

          assert_predicate signup.user, :owner?
          assert_equal "Test Account", signup.account.name
          assert_equal "Feature Ideas", signup.account.boards.first.name
          assert_equal "Owner Example", signup.user.name
          assert_equal "owner@example.com", signup.user.identity.email_address
        end
      end
    end
  end

  test "validates required fields" do
    signup = Signup.new

    assert_not signup.valid?
    assert_equal "can't be blank", signup.errors[:name].first
    assert_equal "can't be blank", signup.errors[:email_address].first
    assert_equal "can't be blank", signup.errors[:password].first
    assert_equal "can't be blank", signup.errors[:account_name].first
  end
end
