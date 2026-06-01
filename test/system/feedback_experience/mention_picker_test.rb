# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class MentionPickerTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
      @idea = ideas(:one)
    end

    test "comment form renders lexxy-prompt with aria-label" do
      sign_in_as(@user)

      visit idea_url(@idea, script_name: @account.slug)

      assert page.has_css?("lexxy-prompt[trigger='@'][aria-label='Mention someone in your account']", visible: :all)
    end

    test "lexxy-prompt src points at prompts_users_path" do
      sign_in_as(@user)

      visit idea_url(@idea, script_name: @account.slug)

      prompt_src = first("lexxy-prompt[trigger='@']", visible: :all)["src"]
      expected_path = Rails.application.routes.url_helpers.prompts_users_path(script_name: @account.slug)

      assert prompt_src.ends_with?(expected_path),
        "expected lexxy-prompt src #{prompt_src.inspect} to end with #{expected_path.inspect}"
    end
  end
end
