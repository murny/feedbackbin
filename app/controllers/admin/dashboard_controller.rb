# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def show
      @stats = Rails.cache.fetch("dashboard_stats_#{Current.organization.id}", expires_in: 1.hour) do
        {
          total_posts: Current.organization.posts.count,
          posts_this_month: Current.organization.posts.where(created_at: 1.month.ago.beginning_of_month..Time.current).count,
          total_users: Current.organization.memberships.count,
          admin_users: Current.organization.memberships.administrator.count,
          total_comments: Current.organization.comments.count,
          comments_this_month: Current.organization.comments.where(created_at: 1.month.ago.beginning_of_month..Time.current).count
        }
      end

      @recent_posts = Rails.cache.fetch("dashboard_recent_posts_#{Current.organization.id}", expires_in: 10.minutes) do
        Current.organization.posts
                            .includes(:author, :category, :post_status)
                            .order(created_at: :desc)
                            .limit(5)
                            .to_a
      end

      @recent_comments = Rails.cache.fetch("dashboard_recent_comments_#{Current.organization.id}", expires_in: 10.minutes) do
        Current.organization.comments
                            .includes(:creator, :post)
                            .order(created_at: :desc)
                            .limit(5)
                            .to_a
      end
    end
  end
end
