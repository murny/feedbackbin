# frozen_string_literal: true

require "test_helper"

module UserSettings
  class WatchesControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
      sign_in_as(@user)
    end

    test "index renders the user's watched ideas" do
      get user_settings_watches_url

      assert_response :success
      assert_select "body", text: /#{Regexp.escape(ideas(:one).title)}/
    end

    test "destroy removes a single watch" do
      watch = watches(:jane_watching_two)

      delete user_settings_watch_url(watch)

      assert_redirected_to user_settings_watches_url
      assert_not watch.reload.watching?
    end

    test "destroy raises RecordNotFound for another user's watch (T-06-05)" do
      other_watch = watches(:shane_watching_one)

      delete user_settings_watch_url(other_watch)

      assert_response :not_found
      assert other_watch.reload.watching?
    end

    test "bulk sets all the user's watching rows to watching=false" do
      assert @user.watches.watching.count >= 2

      delete bulk_user_settings_watches_url

      assert_redirected_to user_settings_watches_url
      assert_equal 0, @user.watches.watching.count
      assert_match(/Unwatched/, flash[:notice])
    end

    test "bulk does NOT touch other users' watches (T-06-05 isolation)" do
      shane = users(:shane)
      shane_watching_before = shane.watches.watching.count
      assert shane_watching_before >= 1

      delete bulk_user_settings_watches_url

      assert_equal shane_watching_before, shane.watches.watching.count
    end
  end
end
