# frozen_string_literal: true

require "test_helper"

class SignupsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    untenanted do
      get signup_url

      assert_response :success
    end
  end

  test "create with all parameters" do
    untenanted do
      assert_difference [ "Account.count", "Board.count", "Identity.count" ], 1 do
        assert_difference "User.count", 2 do  # system user + owner
          assert_difference "Status.count", 4 do
            assert_difference "Idea.count", 3 do  # template ideas
              post signup_url, params: {
                signup: {
                  name: "New Person",
                  email_address: "new@feedbackbin.com",
                  password: "secret123456",
                  account_name: "Test Account"
                }
              }
            end
          end
        end
      end

      account = Account.last

      assert_redirected_to root_url(script_name: account.slug)

      user = account.users.find_by!(role: :owner)

      assert cookies[:session_token]
      assert_equal 1, user.identity.sessions.count
      assert_equal "new@feedbackbin.com", user.identity.email_address
      assert_equal "Test Account", account.name
      assert_predicate user, :owner?
    end
  end

  test "create fails with missing information" do
    untenanted do
      assert_no_difference [ "User.count", "Account.count", "Board.count", "Status.count" ] do
        post signup_url, params: {
          signup: {
            email_address: "new@feedbackbin.com",
            password: "secret123456"
            # Missing: name, account_name (required fields)
          }
        }
      end

      assert_response :unprocessable_entity
    end
  end

  test "redirects to sign in when not accepting signups (single-tenant with existing account)" do
    with_multi_tenant_mode(false) do
      untenanted do
        get signup_url

        assert_redirected_to sign_in_url
      end
    end
  end
end
