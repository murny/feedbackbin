# frozen_string_literal: true

class Ideas::Comments::ReactionsController < ApplicationController
  include IdeaScoped

  before_action :set_comment
  before_action :set_reactable

  with_options only: :destroy do
    before_action :set_reaction
    before_action :ensure_permission_to_administer_reaction
  end

  def index
    render "reactions/index"
  end

  def new
    render "reactions/new"
  end

  def create
    existing = @reactable.reactions.find_by(reacter: Current.user, content: reaction_params[:content])

    if existing
      existing.destroy
    else
      @reactable.reactions.create(reaction_params)
    end

    @reactable.reload

    respond_to do |format|
      format.turbo_stream { render "reactions/create" }
      format.json { head :created }
    end
  end

  def destroy
    @reaction.destroy
    @reactable.reload

    respond_to do |format|
      format.turbo_stream { render "reactions/destroy" }
      format.json { head :no_content }
    end
  end

  private

    def set_comment
      @comment = @idea.comments.find(params[:comment_id])
    end

    def set_reactable
      @reactable = @comment
    end

    def set_reaction
      @reaction = @reactable.reactions.find(params[:id])
    end

    def ensure_permission_to_administer_reaction
      head :forbidden if Current.user != @reaction.reacter
    end

    def reaction_params
      params.expect(reaction: :content)
    end
end
