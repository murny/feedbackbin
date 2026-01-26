# frozen_string_literal: true

module IdeaScoped
  extend ActiveSupport::Concern

  included do
    before_action :set_idea
  end

  private

    def set_idea
      @idea = Current.account.ideas.find(params[:idea_id])
    end
end
