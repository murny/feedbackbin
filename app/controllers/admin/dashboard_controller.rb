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
               .includes(:board, :status, creator: { avatar_attachment: :blob })
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end

      @recent_comments = Rails.cache.fetch("account_#{account.id}/dashboard_recent_comments", expires_in: 10.minutes) do
        account.comments
               .includes(:idea, creator: { avatar_attachment: :blob })
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end

      @ideas_this_week = Rails.cache.fetch("account_#{account.id}/dashboard_ideas_this_week/v1", expires_in: 10.minutes) do
        account.ideas
               .includes(:board, :status, creator: { avatar_attachment: :blob })
               .where(created_at: 7.days.ago..)
               .order(created_at: :desc)
               .limit(5)
               .to_a
      end

      @top_voted_ideas = Rails.cache.fetch("account_#{account.id}/dashboard_top_voted/v1", expires_in: 10.minutes) do
        account.ideas
               .includes(:board, :status, creator: { avatar_attachment: :blob })
               .order(votes_count: :desc, created_at: :desc)
               .limit(5)
               .to_a
      end

      @trending_ideas = Rails.cache.fetch("account_#{account.id}/dashboard_trending/v1", expires_in: 10.minutes) do
        trending_counts = account.votes
                                 .where(voteable_type: "Idea", created_at: 7.days.ago..)
                                 .group(:voteable_id)
                                 .order(Arel.sql("COUNT(*) DESC, voteable_id ASC"))
                                 .limit(5)
                                 .count

        ordered_idea_ids = trending_counts.keys
        next [] if ordered_idea_ids.empty?

        by_id = account.ideas
                       .includes(:board, :status, creator: { avatar_attachment: :blob })
                       .where(id: ordered_idea_ids)
                       .index_by(&:id)

        ordered_idea_ids.map { |id| by_id[id] }.compact.to_a
      end
    end
  end
end
