# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class CmdKTest < ApplicationSystemTestCase
    # global_search_controller.js#handleGlobalKeydown uses metaKey on macOS
    # (per isAppleDevice) and ctrlKey elsewhere. CI runs on Ubuntu, so the
    # browser's navigator.platform is "Linux", not "MacIntel" — the test
    # must mirror that to actually trigger the handler.
    MODIFIER_KEY = (RbConfig::CONFIG["host_os"] =~ /darwin/i) ? :meta : :control

    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
    end

    test "Cmd+K opens search dialog" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ MODIFIER_KEY, "k" ]

      assert_selector "dialog.search-dialog[open]"
    end

    test "empty state shows recently viewed when user has visits" do
      Visit.where(user: @user).destroy_all
      Visit.create!(account: @account, user: @user, idea: ideas(:one), visited_at: 5.minutes.ago)

      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ MODIFIER_KEY, "k" ]

      assert_selector "dialog.search-dialog[open]"
      assert_text(/recently viewed/i)
    end

    test "empty state shows cold-start when no visits" do
      fresh_user = users(:john)
      Visit.where(user: fresh_user).destroy_all

      sign_in_as(fresh_user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ MODIFIER_KEY, "k" ]

      assert_selector "dialog.search-dialog[open]"
      assert_text "Start typing to search"
    end

    test "results show type badges for Idea, Comment, and Changelog" do
      Search::Record.destroy_all
      Search::Record.upsert_for(ideas(:one))
      Search::Record.upsert_for(comments(:one))
      changelogs(:one).reindex

      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ MODIFIER_KEY, "k" ]
      find("input.search-dialog__input").set("dark")

      assert_selector ".search-result__type-badge", text: "Idea"
      assert_selector ".search-result__type-badge", text: "Comment"
      assert_selector ".search-result__type-badge", text: "Changelog"
    end

    test "Enter on highlighted result navigates to it" do
      skip "navigable_list keyboard nav inside <dialog> is flaky under Capybara/Selenium (see 03-VALIDATION.md Manual-Only Verifications)"
    end
  end
end
