# frozen_string_literal: true

require "application_system_test_case"

module RoadmapChangelogs
  class RoadmapMobileTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
    end

    test "roadmap columns stack vertically at narrow viewport" do
      page.driver.browser.manage.window.resize_to(375, 800)

      visit roadmap_url(script_name: @account.slug)

      assert_selector ".roadmap-grid"

      columns = all(".roadmap-column")

      assert_operator columns.size, :>=, 2, "expected at least 2 roadmap columns to verify stacking"

      flex_direction = page.evaluate_script(
        "getComputedStyle(document.querySelector('.roadmap-grid')).flexDirection"
      )

      assert_equal "column", flex_direction

      first_rect = columns.first.evaluate_script("this.getBoundingClientRect()")
      last_rect = columns.last.evaluate_script("this.getBoundingClientRect()")

      assert_operator first_rect["top"], :<, last_rect["top"], "expected first column to render above last column"
    end

    test "roadmap columns remain side-by-side at desktop viewport" do
      page.driver.browser.manage.window.resize_to(1280, 800)

      visit roadmap_url(script_name: @account.slug)

      assert_selector ".roadmap-grid"

      columns = all(".roadmap-column")

      assert_operator columns.size, :>=, 2, "expected at least 2 roadmap columns to verify horizontal layout"

      first_rect = columns.first.evaluate_script("this.getBoundingClientRect()")
      last_rect = columns.last.evaluate_script("this.getBoundingClientRect()")

      assert_in_delta first_rect["top"], last_rect["top"], 1.0, "expected columns to share the same vertical position on desktop"
    end
  end
end
