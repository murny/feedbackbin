# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class ThreadCollapseTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
      @idea = ideas(:one)
      @parent = comments(:two)
      @parent.replies.delete_all
    end

    test "renders no collapse trigger when reply count is below threshold" do
      4.times { |i| build_reply("Below threshold reply #{i + 1}") }

      sign_in_as(@user)
      visit idea_url(@idea, script_name: @account.slug)

      assert_no_css ".replies-toggle"
      assert_text "Below threshold reply 1"
      assert_text "Below threshold reply 4"
    end

    test "renders collapse trigger when reply count meets threshold" do
      5.times { |i| build_reply("Threshold reply #{i + 1}") }

      sign_in_as(@user)
      visit idea_url(@idea, script_name: @account.slug)

      assert_selector ".replies-toggle"
      expected_label = I18n.t("comments.comment.collapsed_replies_toggle.show_more_replies", count: 2)

      assert_selector ".replies-toggle", text: expected_label
      assert_selector ".replies-toggle[aria-expanded='false']"
      assert_selector "[data-toggle-target='toggleable'][aria-hidden='true']", visible: :all
    end

    test "expanding the trigger flips aria attributes" do
      5.times { |i| build_reply("Expanding reply #{i + 1}") }

      sign_in_as(@user)
      visit idea_url(@idea, script_name: @account.slug)

      find(".replies-toggle").click

      assert_selector ".replies-toggle[aria-expanded='true']"
      assert_selector "[data-toggle-target='toggleable'][aria-hidden='false']"
      assert_text "Expanding reply 4"
      assert_text "Expanding reply 5"
    end

    private
      def build_reply(body)
        Comment.create!(
          account: @account,
          idea: @idea,
          parent: @parent,
          creator: @user,
          body: body
        )
      end
  end
end
