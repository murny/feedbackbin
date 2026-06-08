# frozen_string_literal: true

require "application_system_test_case"

module FeedbackExperience
  class SimilarIdeasTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
      @idea = ideas(:one) # "Wish this had dark mode!"
      Search::Record.upsert_for(@idea)
    end

    test "title input shows similar ideas after debounce" do
      sign_in_as(@user)

      visit new_idea_url(script_name: @account.slug)

      fill_in "idea[title]", with: "dark"

      assert_selector ".similar-ideas__item", text: @idea.title
    end

    test "title input below 3 chars does not load suggestions" do
      sign_in_as(@user)

      visit new_idea_url(script_name: @account.slug)

      fill_in "idea[title]", with: "ab"

      sleep 0.5

      assert_no_css ".similar-ideas__item"
    end
  end
end
