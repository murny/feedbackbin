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
  end
end
