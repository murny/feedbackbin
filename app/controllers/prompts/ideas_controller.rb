# frozen_string_literal: true

class Prompts::IdeasController < ApplicationController
  MAX_RESULTS = 10

  def index
    @ideas = if filter_param.present?
      prepending_exact_matches_by_id(search_ideas).first(MAX_RESULTS)
    else
      published_ideas.order(created_at: :desc).limit(MAX_RESULTS)
    end

    if stale? etag: @ideas
      render layout: false
    end
  end

  private

    def filter_param
      params[:filter]
    end

    def search_ideas
      sanitized_filter = ActiveRecord::Base.sanitize_sql_like(filter_param)
      published_ideas
        .where("title LIKE ?", "%#{sanitized_filter}%")
        .order(created_at: :desc)
    end

    def published_ideas
      Current.account.ideas
    end

    def prepending_exact_matches_by_id(ideas)
      parsed_id = Integer(filter_param, exception: false)
      return ideas unless parsed_id&.positive?

      if idea_by_id = published_ideas.find_by(id: parsed_id)
        [ idea_by_id ] + ideas.where.not(id: idea_by_id.id).to_a
      else
        ideas
      end
    end
end
