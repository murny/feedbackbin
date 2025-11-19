# frozen_string_literal: true

class RoadmapController < ApplicationController
  include ModuleEnforcement
  enforce_module :roadmap

  allow_unauthenticated_access only: %i[index]

  # GET /roadmap
  def index
    authorize :roadmap, :index?
    @categories = Category.ordered

    if params[:category_id].present?
      @selected_category = @categories.find_by(id: params[:category_id])
    else
      @selected_category = nil
    end

    @search = params[:search]

    @roadmap_data = roadmap_data(@selected_category, @search)
    @column_count = @roadmap_data.size
  end

  private

    def roadmap_data(selected_category, search_query)
      # Get only post statuses visible on roadmap, ordered by position
      statuses = PostStatus.visible_on_roadmap.ordered

      # Start with all posts for visible statuses
      posts = Post
        .where(post_status_id: statuses.pluck(:id))
        .includes(:author, :category)
        .select(:id, :title, :likes_count, :category_id, :post_status_id, :author_id, :created_at)

      # Apply category filter if selected
      posts = posts.where(category_id: selected_category.id) if selected_category.present?

      # Apply search filter using Post.search method
      posts = posts.search(search_query)

      # Apply sorting using the same pattern as posts index
      posts = posts.sort_by_params(sort_column(Post), sort_direction)

      # Group posts by status in Ruby
      posts_by_status = posts.group_by(&:post_status_id)

      # Build hash of status => posts
      statuses.each_with_object({}) do |status, hash|
        hash[status] = posts_by_status[status.id] || []
      end
    end
end
