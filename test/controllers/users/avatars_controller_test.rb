# frozen_string_literal: true

require "test_helper"

class Users::AvatarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
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
    sign_in @shane

    assert_predicate @shane.avatar, :attached?

    delete user_avatar_url(@shane)

    assert_redirected_to edit_users_settings_profile_url
    assert_not_predicate @shane.reload.avatar, :attached?
  end
end
