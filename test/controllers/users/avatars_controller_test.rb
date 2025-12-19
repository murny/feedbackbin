# frozen_string_literal: true

require "test_helper"

module Users
  class AvatarsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
    end

    test "show initials" do
      get user_avatar_url(@user)

      assert_select "text", text: "JD"
    end

    test "show image" do
      @user.update! avatar: fixture_file_upload("random.jpeg", "image/jpeg")
      get user_avatar_url(@user)

      assert_equal "image/webp", @response.content_type
    end

    test "destroy" do
      @shane = users(:shane)
      sign_in_as @shane

      @shane.update! avatar: fixture_file_upload("random.jpeg", "image/jpeg")

      delete user_avatar_url(@shane)

      assert_redirected_to user_settings_profile_url
      assert_not_predicate @shane.reload.avatar, :attached?
    end
  end
end
