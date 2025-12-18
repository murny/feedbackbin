# frozen_string_literal: true

class RoadmapController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  # GET /roadmap
  def index
    authorize :roadmap, :index?
    @boards = Board.ordered

    if params[:board_id].present?
      @selected_board = @boards.find_by(id: params[:board_id])
    else
      @selected_board = nil
    end

    @search = params[:search]

    @roadmap_data = roadmap_data(@selected_board, @search)
    @column_count = @roadmap_data.size
  end

  private

    def roadmap_data(selected_board, search_query)
      # Get only statuses visible on roadmap, ordered by position
      statuses = Status.visible_on_roadmap.ordered

      # Start with all ideas for visible statuses
      ideas = Idea
        .where(status_id: statuses.pluck(:id))
        .includes(:creator, :board)
        .select(:id, :title, :votes_count, :board_id, :status_id, :creator_id, :created_at)

      # Apply board filter if selected
      ideas = ideas.where(board_id: selected_board.id) if selected_board.present?

      # Apply search filter using Idea.search method
      ideas = ideas.search(search_query)

      # Apply sorting using the same pattern as ideas index
      ideas = ideas.sort_by_params(sort_column(Idea), sort_direction)

      # Group ideas by status in Ruby
      ideas_by_status = ideas.group_by(&:status_id)

      # Build hash of status => ideas
      statuses.each_with_object({}) do |status, hash|
        hash[status] = ideas_by_status[status.id] || []
      end
    end
end
