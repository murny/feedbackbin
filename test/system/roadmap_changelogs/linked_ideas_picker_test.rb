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

    test "edit form renders the combobox-wired idea_ids select with existing links pre-selected" do
      sign_in_as(@admin)

      visit edit_admin_changelog_url(@changelog, script_name: @account.slug)

      assert_selector "select[name='changelog[idea_ids][]'][multiple][data-controller~='combobox']", visible: :all
      assert_selector "select[data-combobox-url-value*='/admin/changelogs/linked_ideas']", visible: :all
    end

    test "new form renders the same combobox-wired idea_ids select" do
      sign_in_as(@admin)

      visit new_admin_changelog_url(script_name: @account.slug)

      assert_selector "select[name='changelog[idea_ids][]'][multiple][data-controller~='combobox']", visible: :all
    end
  end
end
