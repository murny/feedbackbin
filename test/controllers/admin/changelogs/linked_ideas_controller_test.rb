# frozen_string_literal: true

require "test_helper"

module Admin
  module Changelogs
    class LinkedIdeasControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @changelog = changelogs(:one)
        @idea = ideas(:one)
        sign_in_as @admin
      end

      test "returns matching ideas filtered by title" do
        get admin_changelog_linked_ideas_url(@changelog), params: { filter: "dark" }

        assert_response :success
        assert_match @idea.title, response.body
      end

      test "returns empty list when filter blank" do
        get admin_changelog_linked_ideas_url(@changelog)

        assert_response :success
        assert_no_match @idea.title, response.body
      end

      test "rejects non-admin users" do
        sign_in_as users(:john)

        get admin_changelog_linked_ideas_url(@changelog), params: { filter: "dark" }

        assert_response :forbidden
      end

      test "scopes results to the current account" do
        foreign_idea = ideas(:acme_one)

        get admin_changelog_linked_ideas_url(@changelog), params: { filter: "Acme" }

        assert_response :success
        assert_no_match foreign_idea.title, response.body
      end
    end
  end
end
