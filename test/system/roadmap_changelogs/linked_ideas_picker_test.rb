# frozen_string_literal: true

require "application_system_test_case"

module RoadmapChangelogs
  class LinkedIdeasPickerTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @admin = users(:shane)
      @changelog = changelogs(:two)
      @idea = ideas(:one)
    end

    test "admin can search, link, see chip, submit, and persist the join row" do
      sign_in_as(@admin)

      visit edit_admin_changelog_url(@changelog, script_name: @account.slug)

      assert_selector "[data-controller='linked-ideas-picker']"

      fill_in "linked_ideas_filter", with: "dark"

      assert_selector ".linked-ideas-picker__result", text: @idea.title

      find(".linked-ideas-picker__result", text: @idea.title).click

      assert_selector "[data-linked-ideas-picker-chip]", text: @idea.title
      assert_selector(
        "input[name='changelog[idea_ids][]'][value='#{@idea.id}']",
        visible: :hidden
      )

      click_button "Save Changes"

      assert_current_path admin_changelogs_path(script_name: @account.slug)
      assert_includes @changelog.reload.ideas, @idea
    end
  end
end
