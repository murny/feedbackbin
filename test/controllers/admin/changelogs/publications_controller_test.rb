# frozen_string_literal: true

require "test_helper"

module Admin
  module Changelogs
    class PublicationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @published = changelogs(:one)
        @draft = changelogs(:draft)
        sign_in_as @admin
      end

      test "should publish a draft entry" do
        assert_nil @draft.published_at

        post admin_changelog_publication_url(@draft)

        assert_redirected_to admin_changelogs_path
        assert_equal I18n.t("admin.changelogs.publications.create.successfully_published"), flash[:notice]
        assert_not_nil @draft.reload.published_at
      end

      test "should unpublish a published entry" do
        assert_not_nil @published.published_at

        delete admin_changelog_publication_url(@published)

        assert_redirected_to admin_changelogs_path
        assert_equal I18n.t("admin.changelogs.publications.destroy.successfully_unpublished"), flash[:notice]
        assert_nil @published.reload.published_at
      end

      test "non-admin cannot publish" do
        sign_in_as users(:john)

        post admin_changelog_publication_url(@draft)

        assert_response :forbidden
      end

      test "non-admin cannot unpublish" do
        sign_in_as users(:john)

        delete admin_changelog_publication_url(@published)

        assert_response :forbidden
      end
    end
  end
end
