# frozen_string_literal: true

require "application_system_test_case"

module RoadmapChangelogs
  class MentionBannerTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
    end

    test "renders mention banner when idea is linked to a published changelog" do
      idea = ideas(:one)
      changelog = changelogs(:one)

      visit idea_url(idea, script_name: @account.slug)

      assert_selector ".mention-banner"
      assert_selector ".mention-banner", text: changelog.title
      assert_selector ".mention-banner a[href='#{changelog_path(changelog, script_name: @account.slug)}']"
    end

    test "does NOT render mention banner for draft-only linked changelogs" do
      idea = ideas(:two)

      visit idea_url(idea, script_name: @account.slug)

      assert_no_selector ".mention-banner"
    end
  end
end
