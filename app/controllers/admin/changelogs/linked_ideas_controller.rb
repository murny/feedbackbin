# frozen_string_literal: true

module Admin
  module Changelogs
    class LinkedIdeasController < Admin::BaseController
      MAX_RESULTS = 10

      def index
        ideas = if filter_param.present?
          sanitized_filter = ActiveRecord::Base.sanitize_sql_like(filter_param)
          Current.account.ideas
            .where("title LIKE ?", "%#{sanitized_filter}%")
            .order(created_at: :desc)
            .limit(MAX_RESULTS)
        else
          Idea.none
        end

        render json: ideas.map { |idea| { value: idea.id, text: "##{idea.id} #{idea.title}" } }
      end

      private

        def filter_param
          params[:q] || params[:filter]
        end
    end
  end
end
