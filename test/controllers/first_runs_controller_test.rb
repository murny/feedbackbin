# frozen_string_literal: true

require "test_helper"

class FirstRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Account.destroy_all
  end

  test "new is permitted when no accounts exist" do
    get first_run_url

    assert_response :success
  end

  test "new is not permitted when account exist" do
    account = Account.create!(name: "FeedbackBin")
    identity = Identity.create!(
      email_address: "new@feedbackbin.com",
      password: "secret123456"
    )
    User.create!(
      name: "Test User",
      role: :owner,
      account: account,
      identity: identity
    )

    get first_run_url

    assert_redirected_to root_url
  end

  test "create with all parameters" do
    assert_difference [ "User.count", "Account.count", "Board.count", "Identity.count" ], 1 do
      assert_difference "Status.count", 4 do
        post first_run_url, params: {
          first_run: {
            name: "New Person",
            email_address: "new@feedbackbin.com",
            password: "secret123456",
            account_name: "Test Account",
            board_name: "Custom Board",
            board_color: "#3b82f6"
          }
        }
      end
    end

    assert_redirected_to root_url

    user = User.last
    account = Account.last

    assert_equal user.identity.sessions.last.id, parsed_cookies.signed[:session_id]
    assert_equal "new@feedbackbin.com", user.identity.email_address

    assert_equal "Test Account", account.name
    assert_equal "Custom Board", Board.last.name

    assert_predicate user, :owner?
  end

  test "create fails with missing information" do
    assert_no_difference [ "User.count", "Account.count", "Board.count", "Status.count" ] do
      post first_run_url, params: {
        first_run: {
          email_address: "new@feedbackbin.com",
          password: "secret123456"
          # Missing: name, account_name, board_name, board_color (required fields)
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
