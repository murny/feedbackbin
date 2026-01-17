# frozen_string_literal: true

require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:shane)
  end

  test "index shows unread and read notifications" do
    get notifications_path

    assert_response :success

    assert_select "h1", text: I18n.t("notifications.index.heading")
  end

  test "index requires authentication" do
    sign_out
    get notifications_path

    assert_redirected_to users_sign_in_path
  end
end
