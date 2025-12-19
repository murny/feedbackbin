# frozen_string_literal: true

module Admin
  class IdeasController < Admin::BaseController
    def index
      ideas = Idea.includes(:creator, :board)
                .search(params[:search])
                .order(created_at: :desc)

      @pagy, @ideas = pagy(ideas)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @idea = Idea.includes(
              :board,
              :status,
              :rich_text_description,
              creator: { avatar_attachment: :blob }).find(params.expect(:id))

      @recent_comments = @idea.comments.includes(:rich_text_body, creator: { avatar_attachment: :blob }).limit(5).order(created_at: :desc)
    end
  end
end
