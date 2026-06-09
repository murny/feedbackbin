# frozen_string_literal: true

require "application_system_test_case"

module RoadmapChangelogs
  class ShippedBannerTest < ApplicationSystemTestCase
    setup do
      @account = accounts(:feedbackbin)
    end

    test "renders shipped banner when idea is linked to a published changelog" do
      idea = ideas(:one)
      changelog = changelogs(:one)

      visit idea_url(idea, script_name: @account.slug)

      assert_selector ".shipped-banner"
      assert_selector ".shipped-banner", text: changelog.title
      assert_selector ".shipped-banner a[href='#{changelog_path(changelog, script_name: @account.slug)}']"
    end

    test "does NOT render shipped banner for draft-only linked changelogs" do
      idea = ideas(:two)

      visit idea_url(idea, script_name: @account.slug)

      assert_no_selector ".shipped-banner"
    end
  end
end
