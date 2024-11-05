# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_url(users(:one))

    assert_response :success
  end

  test "should be able to delete user" do
    sign_in(users(:one))

    assert_difference("User.count", -1) do
      delete user_url(users(:one))
    end

    assert_redirected_to root_url
    assert_equal "Your account has been deleted.", flash[:notice]
  end
end
