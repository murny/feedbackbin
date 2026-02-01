# frozen_string_literal: true

class Prompts::IdeasController < ApplicationController
  MAX_RESULTS = 10

  def index
    @ideas = if filter_param.present?
      prepending_exact_matches_by_id(search_ideas)
    else
      published_ideas.order(created_at: :desc)
    end.limit(MAX_RESULTS)

    if stale? etag: @ideas
      render layout: false
    end
  end

  private

    def filter_param
      params[:filter]
    end

    def search_ideas
      published_ideas
        .where("title LIKE ?", "%#{filter_param}%")
        .order(created_at: :desc)
    end

    def published_ideas
      Current.account.ideas
    end

    def prepending_exact_matches_by_id(ideas)
      if idea_by_id = published_ideas.find_by(id: filter_param.to_i)
        [ idea_by_id ] + ideas.where.not(id: idea_by_id.id)
      else
        ideas
      end
    end
end
