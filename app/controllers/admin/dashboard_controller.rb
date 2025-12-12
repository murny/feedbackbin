# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def show
      @stats = Rails.cache.fetch("dashboard_stats", expires_in: 1.hour) do
        {
          total_ideas: Idea.count,
          ideas_this_month: Idea.where(created_at: Time.current.beginning_of_month..Time.current).count,
          total_users: User.count,
          admin_users: User.admin.count,
          total_comments: Comment.count,
          comments_this_month: Comment.where(created_at: Time.current.beginning_of_month..Time.current).count
        }
      end

      @recent_ideas = Rails.cache.fetch("dashboard_recent_ideas", expires_in: 10.minutes) do
        Idea.all
            .includes(:author, :board, :status)
            .order(created_at: :desc)
            .limit(5)
            .to_a
      end

      @recent_comments = Rails.cache.fetch("dashboard_recent_comments", expires_in: 10.minutes) do
        Comment.all
               .includes(:creator, :idea)
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end
    end
  end
end
