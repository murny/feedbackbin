# frozen_string_literal: true

module Ideas
  class TaggingsController < ApplicationController
    include IdeaScoped

    def new
      @tagged_with = @idea.tags.alphabetically
      @tags = Current.account.tags.alphabetically.where.not(id: @tagged_with)
      fresh_when etag: [ @tags, @idea.tags ]
    end

    def create
      @idea.toggle_tag_with sanitized_tag_title_param

      respond_to do |format|
        format.turbo_stream
        format.json { head :no_content }
      end
    end

    private

      def sanitized_tag_title_param
        params.required(:tag_title).strip.gsub(/\A#/, "")
      end
  end
end
