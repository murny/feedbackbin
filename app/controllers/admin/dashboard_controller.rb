# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def show
      account = Current.account

      @stats = Rails.cache.fetch("account_#{account.id}/dashboard_stats", expires_in: 1.hour) do
        {
          total_ideas: account.ideas.count,
          ideas_this_month: account.ideas.where(created_at: Time.current.beginning_of_month..).count,
          total_users: account.users.count,
          admin_users: account.users.admin.count,
          total_comments: account.comments.count,
          comments_this_month: account.comments.where(created_at: Time.current.beginning_of_month..).count
        }
      end

      @recent_ideas = Rails.cache.fetch("account_#{account.id}/dashboard_recent_ideas", expires_in: 10.minutes) do
        account.ideas
               .includes(:creator, :board, :status)
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end

      @recent_comments = Rails.cache.fetch("account_#{account.id}/dashboard_recent_comments", expires_in: 10.minutes) do
        account.comments
               .includes(:creator, :idea)
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end
    end
  end
end
