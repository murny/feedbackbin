# frozen_string_literal: true

require "test_helper"

class ChangelogsControllerTest < ActionDispatch::IntegrationTest
  # test that you can see all changelogs (index) and see a specific changelog (show)
  test "should get index" do
    get changelogs_url

    assert_response :success
  end

  test "should get show" do
    changelog = changelogs(:one)

    get changelog_url(changelog)

    assert_response :success
  end

  test "should mark as read if authenticated" do
    freeze_time

    user = users(:one)
    sign_in user

    get changelogs_url

    assert_equal user.reload.changelogs_read_at.to_i, Time.zone.now.to_i
  end
end
