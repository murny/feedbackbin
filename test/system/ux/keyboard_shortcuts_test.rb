# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class KeyboardShortcutsTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
    end

    test "question mark opens the keyboard shortcuts dialog" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("?")

      assert_selector "dialog#keyboard-shortcuts-dialog[open]"
      assert_text I18n.t("shared.keyboard_shortcuts_dialog.title")
    end

    test "question mark does not open dialog when typing in an input" do
      sign_in_as(@user)

      visit new_idea_url(script_name: @account.slug)

      find_field("Title").send_keys("?")

      assert_no_selector "dialog#keyboard-shortcuts-dialog[open]"
    end

    test "escape closes the keyboard shortcuts dialog" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("?")

      assert_selector "dialog#keyboard-shortcuts-dialog[open]"

      find("body").send_keys(:escape)

      assert_no_selector "dialog#keyboard-shortcuts-dialog[open]"
    end
  end
end
