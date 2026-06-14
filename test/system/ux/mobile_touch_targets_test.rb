# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class MobileTouchTargetsTest < ApplicationSystemTestCase
    MOBILE_VIEWPORT = [ 375, 812 ].freeze
    DESKTOP_VIEWPORT = [ 1280, 800 ].freeze
    MIN_TAP_TARGET_PX = 44

    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
      @idea = ideas(:one)

      page.driver.browser.manage.window.resize_to(*MOBILE_VIEWPORT)
      sign_in_as(@user)
    end

    teardown do
      page.driver.browser.manage.window.resize_to(*DESKTOP_VIEWPORT)
    end

    test "header mobile toggle button meets 44px on mobile viewport" do
      visit ideas_url(script_name: @account.slug)

      height = bounding_height(".header__mobile-toggle-btn")

      assert_operator height, :>=, MIN_TAP_TARGET_PX,
        "expected .header__mobile-toggle-btn to be at least #{MIN_TAP_TARGET_PX}px tall on mobile, got #{height}px"
    end

    test "header search trigger meets 44px on mobile viewport" do
      visit ideas_url(script_name: @account.slug)

      height = bounding_height(".header__search-trigger")

      assert_operator height, :>=, MIN_TAP_TARGET_PX,
        "expected .header__search-trigger to be at least #{MIN_TAP_TARGET_PX}px tall on mobile, got #{height}px"
    end

    test "vote trigger meets 44px on mobile viewport" do
      visit idea_url(@idea, script_name: @account.slug)

      height = bounding_height(".vote__trigger")

      assert_operator height, :>=, MIN_TAP_TARGET_PX,
        "expected .vote__trigger to be at least #{MIN_TAP_TARGET_PX}px tall on mobile, got #{height}px"
    end

    test "dialog close button meets 44px on mobile viewport" do
      visit ideas_url(script_name: @account.slug)

      find("body").send_keys("?")

      assert_selector "dialog#keyboard-shortcuts-dialog[open]"
      wait_for_transform_settled("dialog#keyboard-shortcuts-dialog")

      height = bounding_height(".dialog__close")
      width = bounding_width(".dialog__close")

      assert_operator height, :>=, MIN_TAP_TARGET_PX,
        "expected .dialog__close to be at least #{MIN_TAP_TARGET_PX}px tall on mobile, got #{height}px"
      assert_operator width, :>=, MIN_TAP_TARGET_PX,
        "expected .dialog__close to be at least #{MIN_TAP_TARGET_PX}px wide on mobile, got #{width}px"
    end

    test "primary action button meets 44px on mobile viewport" do
      visit new_idea_url(script_name: @account.slug)

      height = bounding_height("form .btn[type='submit']")

      assert_operator height, :>=, MIN_TAP_TARGET_PX,
        "expected the submit .btn to be at least #{MIN_TAP_TARGET_PX}px tall on mobile, got #{height}px"
    end

    private

      def bounding_height(selector)
        page.evaluate_script(
          "document.querySelector(#{selector.to_json}).getBoundingClientRect().height"
        )
      end

      def bounding_width(selector)
        page.evaluate_script(
          "document.querySelector(#{selector.to_json}).getBoundingClientRect().width"
        )
      end

      def wait_for_transform_settled(selector, timeout: 2.0)
        deadline = Time.now + timeout
        while Time.now < deadline
          transform = page.evaluate_script(
            "getComputedStyle(document.querySelector(#{selector.to_json})).transform"
          )
          return if transform == "none" || transform == "matrix(1, 0, 0, 1, 0, 0)"

          sleep 0.05
        end
      end
  end
end
