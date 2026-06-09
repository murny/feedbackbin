# frozen_string_literal: true

module Admin
  module Changelogs
    class LinkedIdeasController < Admin::BaseController
      MAX_RESULTS = 10

      before_action :set_changelog

      def index
        @ideas = if filter_param.present?
          sanitized_filter = ActiveRecord::Base.sanitize_sql_like(filter_param)
          Current.account.ideas
            .where("title LIKE ?", "%#{sanitized_filter}%")
            .order(created_at: :desc)
            .limit(MAX_RESULTS)
        else
          Idea.none
        end

        render layout: false
      end

      private

        def set_changelog
          @changelog = Current.account.changelogs.find(params[:changelog_id])
        end

        def filter_param
          params[:filter]
        end
    end
  end
end
