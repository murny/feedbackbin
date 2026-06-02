# frozen_string_literal: true

class Ideas::SimilarController < ApplicationController
  def index
    @ideas = Idea.similar_to(
      params[:title],
      account: Current.account,
      limit: 3,
      exclude: params[:idea_id].presence
    )

    render partial: "ideas/similar_ideas", locals: { ideas: @ideas, query: params[:title] }
  end
end
