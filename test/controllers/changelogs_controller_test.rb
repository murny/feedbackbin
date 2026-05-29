# frozen_string_literal: true

require "test_helper"

class ChangelogsControllerTest < ActionDispatch::IntegrationTest
  # test that you can see all changelogs (index) and see a specific changelog (show)
  test "should get index" do
    get changelogs_url

    assert_response :success
  end

  test "index renders empty state when no changelogs exist for the account" do
    Changelog.where(account: accounts(:feedbackbin)).destroy_all

    get changelogs_url

    assert_response :success
    assert_includes response.body, "empty-state__title"
    assert_includes response.body, I18n.t("changelogs.index.empty_placeholder")
  end

  test "should get show" do
    changelog = changelogs(:one)

    get changelog_url(changelog)

    assert_response :success
  end

  test "should mark as read if authenticated" do
    freeze_time

    user = users(:jane)
    sign_in_as(user)

    get changelogs_url

    assert_equal user.reload.changelogs_read_at.to_i, Time.zone.now.to_i
  end
end
