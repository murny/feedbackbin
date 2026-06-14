# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class KeyboardNavigationTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
    end

    test "j moves focus to next idea in the list" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("j")

      assert_selector "li[data-navigable-list-target='item'][aria-selected='true']"
    end

    test "k moves focus to previous idea" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("j")
      find("body").send_keys("j")
      find("body").send_keys("k")

      assert_selector "li[data-navigable-list-target='item'][aria-selected='true']"
    end

    test "enter on focused idea navigates to detail page" do
      sign_in_as(@user)

      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("j")
      find("body").send_keys(:enter)

      assert_current_path %r{/ideas/\d+}
    end

    test "v on focused idea casts a vote via the row vote form" do
      sign_in_as(@user)

      idea = ideas(:one)
      idea.votes.where(voter: @user).destroy_all
      initial_count = idea.votes.where(voter: @user).count

      visit ideas_url(script_name: @account.slug)

      target_id = "idea_#{idea.id}"
      find("##{target_id}").send_keys("v")

      assert_selector "##{target_id} [aria-pressed='true']"
      assert_equal initial_count + 1, idea.votes.where(voter: @user).count
    end

    test "back navigation restores focus to last visited item" do
      sign_in_as(@user)

      idea = ideas(:one)
      target_id = "idea_#{idea.id}"

      visit ideas_url(script_name: @account.slug)

      assert_selector "##{target_id}"

      page.execute_script(<<~JS)
        sessionStorage.setItem("lastFocusedItem", "#{target_id}");
        const el = document.getElementById("#{target_id}");
        el.setAttribute("tabindex", "-1");
        el.setAttribute("data-navigable-list-target", "item");
      JS

      click_link idea.title, match: :first

      assert_current_path idea_path(idea, script_name: @account.slug)

      page.go_back

      assert_current_path ideas_path(script_name: @account.slug)

      focused_id = nil
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop do
          focused_id = page.evaluate_script("document.activeElement && document.activeElement.id")
          break if focused_id == target_id
          sleep 0.1
        end
      end

      assert_equal target_id, focused_id
    end
  end
end
