# frozen_string_literal: true

require "test_helper"

class Notifications::BulkReadingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:shane)
  end

  test "create marks all unread notifications as read" do
    notification = notifications(:shane_comment_notification)

    assert_not notification.read?

    post bulk_reading_path

    assert_redirected_to notifications_path

    assert_predicate notification.reload, :read?
  end

  test "create as JSON" do
    notification = notifications(:shane_comment_notification)

    assert_not notification.read?

    post bulk_reading_path, as: :json

    assert_response :no_content

    assert_predicate notification.reload, :read?
  end
end
