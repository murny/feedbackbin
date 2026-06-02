# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class InternalCommentsTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @idea = ideas(:one)
      @internal_comment = comments(:internal_one)
      @internal_body = @internal_comment.body.to_plain_text
    end

    test "admin sees internal comment checkbox on form" do
      sign_in_as(users(:admin))
      visit idea_url(@idea, script_name: @account.slug)

      assert_field "comment[internal]"
    end

    test "member does not see internal comment checkbox on form" do
      sign_in_as(users(:jane))
      visit idea_url(@idea, script_name: @account.slug)

      assert_no_field "comment[internal]"
    end

    test "admin sees internal comment with badge and modifier" do
      sign_in_as(users(:admin))
      visit idea_url(@idea, script_name: @account.slug)

      assert_text @internal_body
      assert_selector ".comment--internal"
      assert_selector ".badge", text: "Internal"
    end

    test "member does not see internal comment body in thread" do
      sign_in_as(users(:jane))
      visit idea_url(@idea, script_name: @account.slug)

      assert_no_css ".comment--internal"
      assert_no_text @internal_body
    end

    test "admin checking internal checkbox restructures the editor surface via :has() (CR-05)" do
      sign_in_as(users(:admin))
      visit idea_url(@idea, script_name: @account.slug)

      assert_selector ".comment-form .comment-editor"
      assert_selector ".comment-form input[name='comment[internal]']"

      check "comment[internal]"

      assert_selector ".comment-form input[name='comment[internal]']:checked"
      assert_selector ".comment-form:has(input[name='comment[internal]']:checked) .comment-editor",
                      visible: :visible,
                      wait: 1
    end

    test "checked internal-comment checkbox renders a non-transparent background (CR-10)" do
      sign_in_as(users(:admin))
      visit idea_url(@idea, script_name: @account.slug)

      assert_selector "input[name='comment[internal]']"

      check "comment[internal]"

      assert_selector "input[name='comment[internal]']:checked"

      bg = nil
      Timeout.timeout(2) do
        loop do
          bg = page.evaluate_script(
            "getComputedStyle(document.querySelector(\"input[name='comment[internal]']:checked\")).backgroundColor"
          )
          break if bg && bg != "rgba(0, 0, 0, 0)" && bg != "transparent" && bg !~ /\/ 0(\.0+)?\)/
          sleep 0.05
        end
      end

      refute_equal "rgba(0, 0, 0, 0)", bg,
                   "checkbox :checked background should not be transparent (got #{bg.inspect})"
      refute_equal "transparent", bg,
                   "checkbox :checked background should not be transparent (got #{bg.inspect})"
    end
  end
end
