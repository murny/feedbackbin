# frozen_string_literal: true

require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      @admin = users(:shane)
      @account = accounts(:feedbackbin)
      sign_in_as @admin
    end

    def with_memory_cache
      original = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      yield
    ensure
      Rails.cache = original
    end

    test "should get show" do
      get admin_root_url

      assert_response :success
    end

    test "show caches @ideas_this_week with up to 5 recent ideas" do
      with_memory_cache do
        get admin_root_url

        assert_response :success
        cached = Rails.cache.read("account_#{@account.id}/dashboard_ideas_this_week/v1")

        assert_kind_of Array, cached
        assert_operator cached.size, :<=, 5
        cached.each do |idea|
          assert_kind_of Idea, idea
          assert_operator idea.created_at, :>=, 7.days.ago
        end
      end
    end

    test "show caches @top_voted_ideas ordered by votes_count desc" do
      with_memory_cache do
        get admin_root_url

        assert_response :success
        cached = Rails.cache.read("account_#{@account.id}/dashboard_top_voted/v1")

        assert_kind_of Array, cached
        assert_operator cached.size, :<=, 5
        vote_counts = cached.map(&:votes_count)

        assert_equal vote_counts.sort.reverse, vote_counts, "expected top_voted ideas to be sorted by votes_count desc"
      end
    end

    test "show caches @trending_ideas based on last-7-day votes" do
      trending_idea = ideas(:two)
      another_idea = ideas(:three)

      @account.votes.where(voteable_type: "Idea").delete_all

      [ users(:shane), users(:jane), users(:john) ].each do |voter|
        @account.votes.create!(voter: voter, voteable: trending_idea, created_at: 1.day.ago)
      end
      @account.votes.create!(voter: users(:shane), voteable: another_idea, created_at: 2.days.ago)

      with_memory_cache do
        get admin_root_url

        assert_response :success
        cached = Rails.cache.read("account_#{@account.id}/dashboard_trending/v1")

        assert_kind_of Array, cached
        assert_operator cached.size, :<=, 5
        assert_equal trending_idea.id, cached.first.id, "expected the most-voted idea in last 7 days to be first"
      end
    end

    test "trending metric uses account-scoped cache key" do
      with_memory_cache do
        get admin_root_url

        assert_response :success
        assert Rails.cache.exist?("account_#{@account.id}/dashboard_trending/v1"),
          "expected account-scoped trending cache key to be populated"
      end
    end

    test "ideas_this_week metric uses account-scoped cache key with v1 suffix" do
      with_memory_cache do
        get admin_root_url

        assert_response :success
        assert Rails.cache.exist?("account_#{@account.id}/dashboard_ideas_this_week/v1"),
          "expected account-scoped ideas_this_week cache key to be populated"
      end
    end

    test "top_voted metric uses account-scoped cache key with v1 suffix" do
      with_memory_cache do
        get admin_root_url

        assert_response :success
        assert Rails.cache.exist?("account_#{@account.id}/dashboard_top_voted/v1"),
          "expected account-scoped top_voted cache key to be populated"
      end
    end
  end
end
