# frozen_string_literal: true

class RoadmapController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  # GET /roadmap
  def index
    authorize :roadmap, :index?
    @roadmap_data = roadmap_data
  end

  private

    def roadmap_data
      # Get all post statuses ordered by position
      statuses = PostStatus.ordered

      # Load all posts for these statuses in a single query
      posts = Post
        .where(post_status_id: statuses.pluck(:id))
        .includes(:author, :category)
        .select(:id, :title, :likes_count, :category_id, :post_status_id, :author_id, :created_at)
        .order(created_at: :desc)

      # Group posts by status in Ruby
      posts_by_status = posts.group_by(&:post_status_id)

      # Build hash of status => posts
      statuses.each_with_object({}) do |status, hash|
        hash[status] = posts_by_status[status.id] || []
      end
    end
end
