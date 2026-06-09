# frozen_string_literal: true

require "test_helper"

module Admin
  module Changelogs
    class LinkedIdeasControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = users(:shane)
        @idea = ideas(:one)
        sign_in_as @admin
      end

      test "returns matching ideas filtered by title" do
        get linked_ideas_admin_changelogs_url, params: { q: "dark" }

        assert_response :success
        assert_match @idea.title, response.body
        body = JSON.parse(response.body)

        assert(body.any? { |row| row["value"] == @idea.id && row["text"].include?(@idea.title) })
      end

      test "returns empty list when filter blank" do
        get linked_ideas_admin_changelogs_url

        assert_response :success
        assert_equal [], JSON.parse(response.body)
      end

      test "rejects non-admin users" do
        sign_in_as users(:john)

        get linked_ideas_admin_changelogs_url, params: { q: "dark" }

        assert_response :forbidden
      end

      test "scopes results to the current account" do
        foreign_idea = ideas(:acme_one)

        get linked_ideas_admin_changelogs_url, params: { q: "Acme" }

        assert_response :success
        assert_no_match foreign_idea.title, response.body
      end

      test "accepts legacy filter param" do
        get linked_ideas_admin_changelogs_url, params: { filter: "dark" }

        assert_response :success
        assert_match @idea.title, response.body
      end
    end
  end
end
