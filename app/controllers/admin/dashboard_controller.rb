# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def show
      @stats = Rails.cache.fetch("dashboard_stats", expires_in: 1.hour) do
        {
          total_posts: Post.count,
          posts_this_month: Post.where(created_at: Time.current.beginning_of_month..Time.current).count,
          total_users: Membership.count,
          admin_users: Membership.administrator.count,
          total_comments: Comment.count,
          comments_this_month: Comment.where(created_at: Time.current.beginning_of_month..Time.current).count
        }
      end

      @recent_posts = Rails.cache.fetch("dashboard_recent_posts", expires_in: 10.minutes) do
        Post.all
            .includes(:author, :category, :post_status)
            .order(created_at: :desc)
            .limit(5)
            .to_a
      end

      @recent_comments = Rails.cache.fetch("dashboard_recent_comments", expires_in: 10.minutes) do
        Comment.all
               .includes(:creator, :post)
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end
    end
  end
end
