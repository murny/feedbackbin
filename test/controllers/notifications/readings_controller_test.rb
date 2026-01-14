# frozen_string_literal: true

require "test_helper"

class Notifications::ReadingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:shane)
  end

  test "create marks notification as read" do
    notification = notifications(:shane_comment_notification)

    assert_changes -> { notification.reload.read? }, from: false, to: true do
      post notification_reading_path(notification), as: :turbo_stream

      assert_response :success
    end
  end

  test "destroy marks notification as unread" do
    notification = notifications(:shane_idea_notification)

    assert_changes -> { notification.reload.read? }, from: true, to: false do
      delete notification_reading_path(notification), as: :turbo_stream

      assert_response :success
    end
  end

  test "create as JSON" do
    notification = notifications(:shane_comment_notification)

    assert_changes -> { notification.reload.read? }, from: false, to: true do
      post notification_reading_path(notification), as: :json

      assert_response :no_content
    end
  end

  test "destroy as JSON" do
    notification = notifications(:shane_idea_notification)

    assert_changes -> { notification.reload.read? }, from: true, to: false do
      delete notification_reading_path(notification), as: :json

      assert_response :no_content
    end
  end
end
