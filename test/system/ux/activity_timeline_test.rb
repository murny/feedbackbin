# frozen_string_literal: true

require "application_system_test_case"

module Ux
  class ActivityTimelineTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
      @idea = ideas(:one)
      @idea.events.destroy_all

      11.times do |i|
        Event.create!(
          account: @account,
          board: @idea.board,
          creator: @user,
          eventable: @idea,
          action: "idea_title_changed",
          particulars: { old_title: "Title #{i}", new_title: "Title #{i + 1}" }
        )
      end
    end

    test "show all activity expands the full event list inline" do
      sign_in_as(@user)

      visit idea_url(@idea, script_name: @account.slug)

      assert_selector ".activity-timeline__entry", count: 10
      assert_selector ".activity-timeline__show-all"

      click_link I18n.t("ideas.activity_timeline.show_all")

      assert_selector ".activity-timeline__entry", count: 11
      assert_no_selector ".activity-timeline__show-all"
    end
  end
end
