# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class VoteAnimationTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:jane)
      @idea = ideas(:one)
    end

    test "vote button toggles aria-pressed on click" do
      sign_in_as(@user)

      visit idea_url(@idea, script_name: @account.slug)

      idea_button = first(".vote__trigger", visible: true)

      assert_equal "false", idea_button["aria-pressed"]

      idea_button.click

      assert_selector ".vote__trigger[aria-pressed='true']", match: :first

      first(".vote__trigger[aria-pressed='true']").click

      assert_no_selector ".vote__trigger[aria-pressed='true']"
    end

    test "vote rollback shows error toast when the controller raises RecordInvalid" do
      Idea.any_instance.stubs(:vote).raises(ActiveRecord::RecordInvalid.new(@idea))

      sign_in_as(@user)

      visit idea_url(@idea, script_name: @account.slug)

      idea_button = first(".vote__trigger", visible: true)
      idea_button.click

      assert_text I18n.t("ideas.votes.update.error")
      assert_no_selector ".vote__trigger[aria-pressed='true']"
    end
  end
end
