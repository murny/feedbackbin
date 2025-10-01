# frozen_string_literal: true

require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      sign_in_as @admin
    end

    test "should get index" do
      get admin_users_path

      assert_response :success
      assert_includes @response.body, "Users"
    end

    test "should get index with search" do
      get admin_users_path, params: { search: "shane" }

      assert_response :success
    end

    test "should get index as turbo_stream" do
      get admin_users_path, as: :turbo_stream

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", @response.media_type
    end

    test "should show user" do
      user = users(:one)
      get admin_user_path(user)

      assert_response :success
      assert_includes @response.body, user.name
    end

    test "should require authentication" do
      sign_out
      get admin_users_path

      assert_redirected_to sign_in_path
    end
  end
end
