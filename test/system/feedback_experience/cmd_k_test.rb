# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class CmdKTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
    end

    test "Cmd+K opens search dialog" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ :meta, "k" ]

      assert_selector "dialog.search-dialog[open]"
    end

    test "empty state shows two columns when user has visits and queries" do
      Visit.where(user: @user).destroy_all
      Visit.create!(account: @account, user: @user, idea: ideas(:one), visited_at: 5.minutes.ago)
      Search::Query.where(user: @user).destroy_all
      Search::Query.create!(account: @account, user: @user, terms: "dark")

      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ :meta, "k" ]

      assert_selector "dialog.search-dialog[open]"
      assert_selector ".search-empty--two-column"
      assert_text "Recently viewed"
      assert_text "Recent searches"
    end

    test "empty state shows cold-start when no visits and no queries" do
      fresh_user = users(:john)
      Visit.where(user: fresh_user).destroy_all
      Search::Query.where(user: fresh_user).destroy_all

      sign_in_as(fresh_user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys [ :meta, "k" ]

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

      find("body").send_keys [ :meta, "k" ]
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
