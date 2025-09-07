# frozen_string_literal: true

module Admin
  class DashboardController < Admin::BaseController
    def show
      @stats = {
        total_posts: Current.organization.posts.count,
        posts_this_month: Current.organization.posts.where(created_at: 1.month.ago.beginning_of_month..Time.current).count,
        total_users: Current.organization.memberships.count,
        admin_users: Current.organization.memberships.administrator.count,
        total_comments: Current.organization.comments.count,
        comments_this_month: Current.organization.comments.where(created_at: 1.month.ago.beginning_of_month..Time.current).count
      }

      @recent_posts = Current.organization.posts
                                          .includes(:author, :category, :post_status)
                                          .order(created_at: :desc)
                                          .limit(5)

      @recent_activity = Recent.activity_for_organization(Current.organization)
                                .limit(10)
    rescue => e
      Rails.logger.error "Dashboard stats error: #{e.message}"
      @stats = {}
      @recent_posts = Current.organization.posts.none
      @recent_activity = []
    end

    private

      class Recent
        def self.activity_for_organization(organization)
          # Get recent posts and comments for activity feed
          posts = organization.posts.includes(:author)
                             .order(created_at: :desc)
                             .limit(5)
                             .map { |post|
                               {
                                 type: "post",
                                 author: post.author,
                                 title: post.title,
                                 created_at: post.created_at,
                                 url: Rails.application.routes.url_helpers.post_path(post)
                               }
                             }

          comments = organization.comments.includes(:user, :post)
                                         .order(created_at: :desc)
                                         .limit(5)
                                         .map { |comment|
                                           {
                                             type: "comment",
                                             author: comment.user,
                                             title: "Commented on \"#{comment.post.title}\"",
                                             created_at: comment.created_at,
                                             url: Rails.application.routes.url_helpers.post_path(comment.post)
                                           }
                                         }

          (posts + comments).sort_by { |item| item[:created_at] }.reverse
        end
      end
  end
end
