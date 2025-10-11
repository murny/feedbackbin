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
      statuses = PostStatus.ordered.includes(posts: [ :author, :category ])

      # Build hash of status => posts
      statuses.each_with_object({}) do |status, hash|
        hash[status] = status.posts
          .select(:id, :title, :likes_count, :category_id, :post_status_id, :author_id, :created_at)
          .order(created_at: :desc)
      end
    end
end
