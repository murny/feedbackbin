# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class MobileDrawerTest < ApplicationSystemTestCase
    MOBILE_VIEWPORT = [ 375, 812 ].freeze
    DESKTOP_VIEWPORT = [ 1280, 800 ].freeze

    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)

      page.driver.browser.manage.window.resize_to(*MOBILE_VIEWPORT)
      sign_in_as(@user)
    end

    teardown do
      page.driver.browser.manage.window.resize_to(*DESKTOP_VIEWPORT)
    end

    test "mobile menu button opens the drawer dialog" do
      visit ideas_url(script_name: @account.slug)

      find(".header__mobile-toggle-btn").click

      assert_selector "dialog#mobile-menu[open]"
      assert_selector ".drawer.drawer--inline-start[open]"
    end

    test "drawer close button closes the dialog" do
      visit ideas_url(script_name: @account.slug)

      find(".header__mobile-toggle-btn").click

      assert_selector "dialog#mobile-menu[open]"

      find(".drawer__close").click

      assert_no_selector "dialog#mobile-menu[open]"
    end

    test "escape key closes the drawer" do
      visit ideas_url(script_name: @account.slug)

      find(".header__mobile-toggle-btn").click

      assert_selector "dialog#mobile-menu[open]"

      find("body").send_keys(:escape)

      assert_no_selector "dialog#mobile-menu[open]"
    end

    test "turbo navigation closes the drawer" do
      visit ideas_url(script_name: @account.slug)

      find(".header__mobile-toggle-btn").click

      assert_selector "dialog#mobile-menu[open]"

      within "dialog#mobile-menu" do
        click_link I18n.t("application.navbar.links.ideas")
      end

      assert_no_selector "dialog#mobile-menu[open]"
    end
  end
end
