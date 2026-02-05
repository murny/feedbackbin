# frozen_string_literal: true

module Ideas
  class TaggingsController < ApplicationController
    include IdeaScoped

    before_action :ensure_permission_to_administer_idea

    def new
      @tagged_with = @idea.tags.alphabetically
      @tags = Current.account.tags.alphabetically.where.not(id: @tagged_with)
      fresh_when etag: [ @tags, @idea.tags ]
    end

    def create
      @idea.toggle_tag_with sanitized_tag_title_param

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back fallback_location: idea_path(@idea) }
        format.json { head :no_content }
      end
    end

    def destroy
      @tagging = @idea.taggings.find(params[:id])
      @tagging.destroy

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(@tagging.tag, :tag_for_idea) }
        format.html { redirect_to @idea, notice: t(".successfully_removed") }
        format.json { head :no_content }
      end
    end

    private

      def sanitized_tag_title_param
        title = params.require(:tag_title).strip.delete_prefix("#")
        raise ActionController::ParameterMissing, :tag_title if title.blank?
        title
      end
  end
end
